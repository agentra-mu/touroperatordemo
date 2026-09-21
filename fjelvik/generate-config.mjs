// Runs as this project's Vercel Build Command (see vercel.json). Writes
// assets/js/config.js from environment variables set in the Vercel project
// settings, so the real Supabase URL/anon key never need to be committed —
// same values the dashboard project uses, just under plain (non-NEXT_PUBLIC)
// names since this isn't a Next.js app.
import { writeFileSync } from "node:fs";

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_ANON_KEY;

if (!url || !key) {
  console.error(
    "Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables — set them in the Vercel project settings."
  );
  process.exit(1);
}

const contents = `// Auto-generated at build time by generate-config.mjs — do not edit directly.
export const SUPABASE_URL = ${JSON.stringify(url)};
export const SUPABASE_ANON_KEY = ${JSON.stringify(key)};
`;

writeFileSync(new URL("./assets/js/config.js", import.meta.url), contents);
console.log("Wrote assets/js/config.js");
