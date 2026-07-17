import 'dotenv/config';
import cors from 'cors';
import express from 'express';
import multer from 'multer';
import OpenAI from 'openai';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { requireAuthenticatedUser } from './middleware/requireAuthenticatedUser.js';
import { pathToFileURL } from 'node:url';

const app = express();
const rawPort = process.env.PORT?.trim() || '3000';
const port = Number.parseInt(rawPort, 10);
if (!/^\d+$/.test(rawPort) || port < 1 || port > 65535) {
  console.error(`Invalid PORT: ${rawPort}. Use a number from 1 to 65535.`);
  process.exit(1);
}

function isInvalidEnvironmentValue(value) {
  const normalized = value?.trim().toLowerCase() || '';
  return !normalized || [
    'your-project',
    'your_project',
    'your_real',
    'replace_with',
    'placeholder',
  ].some((fragment) => normalized.includes(fragment));
}

const requiredEnvironmentVariables = [
  'OPENAI_API_KEY',
  'SUPABASE_URL',
  'SUPABASE_PUBLISHABLE_KEY',
];
const invalidEnvironmentVariables = requiredEnvironmentVariables.filter(
  (name) => isInvalidEnvironmentValue(process.env[name]),
);
if (invalidEnvironmentVariables.length) {
  const configurationStatus = (name) => {
    const value = process.env[name]?.trim();
    if (!value) return 'missing';
    return isInvalidEnvironmentValue(value) ? 'placeholder' : 'configured';
  };
  console.error('Backend startup stopped.\n');
  console.error('Configuration:');
  console.error(`- PORT: configured as ${port}`);
  for (const name of requiredEnvironmentVariables) {
    console.error(`- ${name}: ${configurationStatus(name)}`);
  }
  console.error(`\nNo server was started. Port ${port} remains free.`);
  console.error('/health is unreachable because the backend process is not running.');
  process.exit(1);
}

const apiKey = process.env.OPENAI_API_KEY.trim();

const openai = new OpenAI({ apiKey, timeout: 60000 });
const allowed = new Set((process.env.ALLOWED_ORIGINS || '').split(',').map((v) => v.trim()).filter(Boolean));
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 20 * 1024 * 1024, files: 1 },
  fileFilter: (_req, file, done) => done(null, ['image/png', 'image/jpeg', 'image/webp'].includes(file.mimetype)),
});

app.disable('x-powered-by');
app.use(helmet());
app.use(cors({
  origin(origin, done) {
    let local = false;
    if (origin) {
      try {
        const url = new URL(origin);
        local = (url.protocol === 'http:' || url.protocol === 'https:') &&
          (url.hostname === 'localhost' || url.hostname === '127.0.0.1');
      } catch {
        local = false;
      }
    }
    done(null, !origin || local || allowed.has(origin));
  },
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '2mb' }));
app.get('/health', (_req, res) => res.json({ status: 'ok', service: 'UNO AI', version: '1.0' }));

const aiLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests. Try again later.' },
});

app.post('/api/cards/transcribe', aiLimiter, requireAuthenticatedUser, upload.single('image'), async (req, res, next) => {
  try {
    if (!req.file) return res.status(415).json({ error: 'Use PNG, JPEG, or WebP.' });
    const { cardId, deckId, title, mode = 'exact' } = req.body;
    if (![cardId, deckId, title].every((v) => typeof v === 'string' && v)) {
      return res.status(400).json({ error: 'Missing card fields.' });
    }
    const prompt = mode === 'clean'
      ? 'Transcribe every readable word. Normalize spacing and line-wrap artifacts only. Preserve language and wording. Mark uncertain text [uncertain] and unreadable text [unreadable]. Return plain text.'
      : 'Transcribe every readable word exactly. Preserve language, punctuation and meaningful line breaks. Do not summarize, explain, translate or invent. Mark uncertain text [uncertain] and unreadable text [unreadable]. Return plain text.';
    const result = await openai.responses.create({
      model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
      input: [{ role: 'user', content: [
        { type: 'input_text', text: prompt },
        { type: 'input_image', image_url: `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`, detail: 'high' },
      ] }],
    });
    const text = (result.output_text || '').trim();
    if (!text) return res.status(502).json({ error: 'No readable text was detected.' });
    res.json({
      cardId,
      transcription: text,
      language: 'und',
      exactText: mode === 'exact' ? text : '',
      cleanedText: mode === 'clean' ? text : null,
      detectedLanguage: 'und',
      status: /\[(uncertain|unreadable)\]/.test(text) ? 'needsReview' : 'unreviewed',
      model: result.model || process.env.OPENAI_MODEL || 'gpt-4o-mini',
      requestId: result.id,
      createdAt: new Date().toISOString(),
    });
  } catch (error) { next(error); }
});

app.post('/api/cards/chat', aiLimiter, requireAuthenticatedUser, async (req, res, next) => {
  try {
    const { cardId, deckId, title, cardTitle, transcription, message, history = [] } = req.body || {};
    if (![cardId, deckId, transcription, message].every((v) => typeof v === 'string') || !Array.isArray(history)) {
      return res.status(400).json({ error: 'Invalid card discussion request.' });
    }
    const safeHistory = history.slice(-12).map((item) => ({
      role: item.role === 'assistant' ? 'assistant' : 'user',
      content: String(item.content || '').slice(0, 8000),
    }));
    const instructions = `Discuss only this Chanson a Repondre card. Ground answers in the transcription and label uncertainty. Card: ${title || cardTitle || cardId}. Transcription:\n${transcription}`;
    const result = await openai.responses.create({
      model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
      instructions,
      input: [...safeHistory, { role: 'user', content: message }],
    });
    const reply = (result.output_text || '').trim();
    if (!reply) return res.status(502).json({ error: 'The AI response was empty.' });
    res.json({
      cardId,
      reply,
      message: reply,
      model: result.model || process.env.OPENAI_MODEL || 'gpt-4o-mini',
      requestId: result.id,
      createdAt: new Date().toISOString(),
    });
  } catch (error) { next(error); }
});

app.use((error, _req, res, _next) => {
  const status = error?.status || (error?.code === 'LIMIT_FILE_SIZE' ? 413 : 500);
  const message = status === 413 ? 'Card image is too large.' : status === 429 ? 'AI service rate limit reached.' : status >= 500 ? 'AI service unavailable.' : 'Invalid request.';
  res.status(status).json({ error: message });
});

export { app };

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  app.listen(port, '0.0.0.0', () => {
    console.log(`UNO AI backend listening on http://127.0.0.1:${port}`);
  });
}
