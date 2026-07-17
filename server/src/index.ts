import 'dotenv/config';
import cors from 'cors';
import express from 'express';
import rateLimit from 'express-rate-limit';
import cards from './routes/cards.js';

const app = express();
const allowed = new Set((process.env.ALLOWED_ORIGINS ?? '').split(',').map((v) => v.trim()).filter(Boolean));

app.disable('x-powered-by');
app.use(cors({
  origin(origin, callback) {
    if (!origin || allowed.has(origin)) callback(null, true);
    else callback(new Error('Origin not allowed'));
  },
}));
app.use(express.json({ limit: '28mb', type: 'application/json' }));
app.use(rateLimit({ windowMs: 60_000, limit: 30, standardHeaders: true, legacyHeaders: false }));
app.get('/health', (_req, res) =>
  res.json({ status: 'ok', service: 'card-ai', version: '1.0.0' }),
);
app.use('/api/cards', cards);
app.use((error: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  const tooLarge = error instanceof Error && 'type' in error && error.type === 'entity.too.large';
  res.status(tooLarge ? 413 : 400).json({
    error: { code: tooLarge ? 'request_too_large' : 'bad_request', message: tooLarge ? 'Request is too large.' : 'Invalid request.' },
  });
});

const port = Number(process.env.PORT ?? 3000);
app.listen(port, () => console.log(`Card AI proxy listening on port ${port}`));
