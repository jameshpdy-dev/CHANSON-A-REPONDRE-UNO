# Card AI proxy

This server keeps `OPENAI_API_KEY` outside Flutter binaries and forwards validated card requests to the OpenAI Responses API.

Requires Node.js 20 LTS or newer. On Windows, install the current Node.js LTS release and restart the terminal, then verify `node --version` and `npm --version`.

```powershell
Copy-Item .env.example .env
npm install
npm start
```

Replace `OPENAI_API_KEY`, `SUPABASE_URL`, and `SUPABASE_PUBLISHABLE_KEY` placeholders in `.env` before startup. The server deliberately exits when required values or the port are invalid. Restrict `ALLOWED_ORIGINS`, and use HTTPS in production.

Flutter authenticates directly with Supabase, then sends `Authorization: Bearer SUPABASE_ACCESS_TOKEN`. The shared middleware verifies that token with Supabase before either AI route can consume paid resources. `GET /health` remains public.

The exact startup command is `npm start`, which runs `node src/index.js`. Verify it from another terminal:

```powershell
Invoke-RestMethod http://127.0.0.1:3000/health
```

The proxy accepts PNG/JPEG/WebP images up to 20 MB and never logs images, transcription text, or API keys. Local browser origins on `localhost` and `127.0.0.1` are allowed on variable ports; production origins must be listed in `ALLOWED_ORIGINS`.
