import test from 'node:test';
import assert from 'node:assert/strict';

process.env.OPENAI_API_KEY = 'test-openai-key';
process.env.SUPABASE_URL = 'https://project-ref.supabase.co';
process.env.SUPABASE_PUBLISHABLE_KEY = 'test-publishable-key';

const { app } = await import('../src/index.js');

async function withServer(action) {
  const server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  const address = server.address();
  try {
    await action(`http://127.0.0.1:${address.port}`);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

test('health route is public', () => withServer(async (baseUrl) => {
  const response = await fetch(`${baseUrl}/health`);
  assert.equal(response.status, 200);
  assert.equal((await response.json()).status, 'ok');
}));

test('card transcription requires a bearer token', () => withServer(async (baseUrl) => {
  const response = await fetch(`${baseUrl}/api/cards/transcribe`, {
    method: 'POST',
  });
  assert.equal(response.status, 401);
  const body = await response.json();
  assert.equal(body.error.code, 'authentication_required');
}));

test('card chat rejects a malformed bearer token', () => withServer(async (baseUrl) => {
  const response = await fetch(`${baseUrl}/api/cards/chat`, {
    method: 'POST',
    headers: { Authorization: 'Token invalid' },
  });
  assert.equal(response.status, 401);
}));

test('card chat rejects a development bypass token', () => withServer(async (baseUrl) => {
  const response = await fetch(`${baseUrl}/api/cards/chat`, {
    method: 'POST',
    headers: { Authorization: 'Bearer fake-development-token' },
  });
  assert.equal(response.status, 401);
  const body = await response.json();
  assert.equal(body.error.code, 'invalid_authentication_token');
}));
