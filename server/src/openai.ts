const endpoint = 'https://api.openai.com/v1/responses';

export async function createResponse(payload: unknown): Promise<Response> {
  const key = process.env.OPENAI_API_KEY;
  if (!key) throw new Error('OPENAI_API_KEY is not configured');
  return fetch(endpoint, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${key}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify(payload),
    signal: AbortSignal.timeout(60_000),
  });
}
