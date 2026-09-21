// Thin wrapper around the Supabase JS SDK (loaded from a CDN, since this is
// a plain static site with no build step) — mirrors dashboard/lib/supabase.ts
// so both apps talk to the same `booking` schema the same way.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

let config;
try {
  config = await import("./config.js");
} catch {
  config = null;
}

let client = null;

export function getSupabase() {
  if (!config || !config.SUPABASE_URL || !config.SUPABASE_ANON_KEY) {
    throw new Error(
      "Missing Supabase config — copy assets/js/config.example.js to assets/js/config.js and fill in your project's URL and anon key."
    );
  }
  if (!client) {
    client = createClient(config.SUPABASE_URL, config.SUPABASE_ANON_KEY, {
      db: { schema: "booking" },
    });
  }
  return client;
}
