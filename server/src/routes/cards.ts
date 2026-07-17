import { Router } from 'express';
import multer from 'multer';
import { createResponse } from '../openai.js';

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 20 * 1024 * 1024, files: 1 },
  fileFilter: (_req, file, done) =>
    done(null, ['image/png', 'image/jpeg', 'image/webp'].includes(file.mimetype)),
});

function outputText(json: any): string {
  return (json.output ?? [])
    .flatMap((item: any) => item.content ?? [])
    .filter((item: any) => item.type === 'output_text')
    .map((item: any) => item.text ?? '')
    .join('\n')
    .trim();
}

router.post('/transcribe', upload.single('image'), async (req, res) => {
  if (!req.file) {
    res.status(415).json({ error: { code: 'unsupported_media', message: 'Use PNG, JPEG, or WebP.' } });
    return;
  }
  const { cardId, deckId, title, mode } = req.body;
  if (![cardId, deckId, title, mode].every((value) => typeof value === 'string')) {
    res.status(400).json({ error: { code: 'invalid_request', message: 'Missing card fields.' } });
    return;
  }
  const instruction = mode === 'clean'
    ? 'Transcribe every readable word. Normalize spacing and broken line wraps only. Preserve language and wording. Mark uncertain text [uncertain] and unreadable text [unreadable]. Return plain text.'
    : 'Transcribe every readable word exactly. Preserve language, punctuation and meaningful line breaks. Do not summarize, explain, translate, or invent. Mark uncertain text [uncertain] and unreadable text [unreadable]. Return plain text.';
  const upstream = await createResponse({
    model: 'gpt-4o-mini',
    input: [{ role: 'user', content: [
      { type: 'input_text', text: instruction },
      { type: 'input_image', image_url: `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}` },
    ] }],
  });
  const json = await upstream.json() as any;
  if (!upstream.ok) {
    res.status(upstream.status).json({ error: { code: 'openai_error', message: 'AI transcription failed.' } });
    return;
  }
  const text = outputText(json);
  if (!text) {
    res.status(502).json({ error: { code: 'empty_response', message: 'No readable text was detected.' } });
    return;
  }
  res.json({
    cardId,
    exactText: mode === 'exact' ? text : '',
    cleanedText: mode === 'clean' ? text : null,
    detectedLanguage: 'und',
    status: /\[(uncertain|unreadable)\]/.test(text) ? 'needsReview' : 'unreviewed',
    model: json.model ?? 'gpt-4o-mini',
    requestId: upstream.headers.get('x-request-id') ?? json.id ?? null,
    createdAt: new Date().toISOString(),
  });
});

router.post('/chat', async (req, res) => {
  const { cardId, deckId, cardTitle, category, tags, transcription, mode, message, history } = req.body ?? {};
  if (![cardId, deckId, cardTitle, category, transcription, mode, message].every((value) => typeof value === 'string') || !Array.isArray(tags) || !Array.isArray(history)) {
    res.status(400).json({ error: { code: 'invalid_request', message: 'Invalid card discussion request.' } });
    return;
  }
  const recent = history.slice(-12).map((item: any) => `${item.role}: ${item.content}`).join('\n');
  const prompt = `You are the card discussion assistant for Chanson a Repondre. Ground answers in the transcription. Clearly label inference and uncertainty. Never diagnose real people.\nCard: ${cardTitle}\nCategory: ${category}\nTags: ${tags.join(', ')}\nMode: ${mode}\nTranscription:\n${transcription}\nRecent messages:\n${recent}\nUser: ${message}`;
  const upstream = await createResponse({ model: 'gpt-4o-mini', input: prompt });
  const json = await upstream.json() as any;
  if (!upstream.ok) {
    res.status(upstream.status).json({ error: { code: 'openai_error', message: 'AI discussion failed.' } });
    return;
  }
  const responseMessage = outputText(json);
  if (!responseMessage) {
    res.status(502).json({ error: { code: 'empty_response', message: 'The AI response was empty.' } });
    return;
  }
  res.json({
    cardId,
    message: responseMessage,
    model: json.model ?? 'gpt-4o-mini',
    requestId: upstream.headers.get('x-request-id') ?? json.id ?? null,
    createdAt: new Date().toISOString(),
  });
});

export default router;
