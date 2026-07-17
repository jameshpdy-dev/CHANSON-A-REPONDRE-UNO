import { getSupabaseAuthClient } from '../services/supabase.js';

export async function requireAuthenticatedUser(request, response, next) {
  const authorization = request.headers.authorization || '';
  const match = /^Bearer\s+(.+)$/i.exec(authorization);
  if (!match) {
    return response.status(401).json({
      error: {
        code: 'authentication_required',
        message: 'Authentication required.',
      },
    });
  }

  const token = match[1].trim();
  if (!token) {
    return response.status(401).json({
      error: {
        code: 'missing_authentication_token',
        message: 'Authentication token is missing.',
      },
    });
  }
  if (token === 'test-token' || token === 'fake-development-token') {
    return response.status(401).json({
      error: {
        code: 'invalid_authentication_token',
        message: 'Authentication token is invalid or expired.',
      },
    });
  }

  try {
    const { data, error } = await getSupabaseAuthClient().auth.getUser(token);
    if (error || !data.user) {
      return response.status(401).json({
        error: {
          code: 'invalid_authentication_token',
          message: 'Authentication token is invalid or expired.',
        },
      });
    }
    request.authUser = {
      id: data.user.id,
      email: data.user.email || null,
    };
    return next();
  } catch (error) {
    console.error(
      'Supabase authentication verification failed:',
      error instanceof Error ? error.message : 'Unknown error',
    );
    return response.status(503).json({
      error: {
        code: 'authentication_service_unavailable',
        message: 'The authentication service is unavailable.',
      },
    });
  }
}
