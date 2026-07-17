import { createClient } from '@supabase/supabase-js';

let client;

export function getSupabaseAuthClient() {
  client ??= createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_PUBLISHABLE_KEY,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false,
      },
    },
  );
  return client;
}
