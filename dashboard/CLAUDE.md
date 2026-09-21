# Owner Dashboard — CLAUDE.md

## Architecture rules

- **Store seam**: All state mutations live in `lib/store.ts`. Components are
  presentational and call store actions — they never touch mock data directly.
  This is the single seam for the future Supabase swap; only `store.ts` imports
  from `mock-data.ts`.

- **Presentational components**: Components call store actions via the
  `useRequests()` hook. They never import mock data or mutate state directly.

- **TDD on logic, not UI**: Tests cover store logic (`validateTotalAmount`,
  `requestReducer`, etc.). Presentational components (cards, badges, dialogs)
  do not need unit tests.

- **Direct-Supabase demo build**: all reads/writes go directly dashboard ↔
  Supabase via the SDK, including `sendPayment`/`declineRequest` in
  `lib/store.tsx` (see CONTEXT.md's DEMO SIMPLIFICATION note — production
  originally routed those two through an n8n webhook that created a
  QuickBooks invoice + MobiPaid link + email; this demo has none of that
  infra, so they just write `status` directly). Supabase Realtime (subscribed
  in `RequestProvider`) still reflects writes back to the UI, which matters
  once the website (a separate static app) also writes to the same tables.
