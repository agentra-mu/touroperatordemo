# CONTEXT.md — Owner Dashboard (Booking Manager)

Project glossary and durable decisions. The agent should read this at the start
of each session and add new terms here as they're coined.

## What this is
A single-owner dashboard for a tourism booking-request platform. The owner
manually reviews booking **requests**. There is NO booking engine and NO
availability logic — the owner approves each request by hand and sets prices
case by case.

## The request lifecycle (status machine)
A request moves through these statuses (real `booking.requests.status` enum):
- `pending_review` — just came in, owner hasn't acted yet
- `declined` — owner rejected it
- `approved` — reserved by the schema; the dashboard's approve action currently
  skips straight from `pending_review` to `awaiting_payment` (see below)
- `awaiting_payment` — owner approved with a price, n8n created a QuickBooks
  invoice + MobiPaid payment link and emailed the customer
- `confirmed` — MobiPaid confirmed payment; n8n flips this automatically
- `reminded` — a reminder was sent (WF-4, cron-based, no dashboard involvement)
- `completed` — activity done
- `cancelled` — cancelled after the fact

## The core flow: approve & send payment, or decline
Two owner actions on a `pending_review` request:
1. **Approve** — owner enters a total price in the "Approve & Send Payment"
   dialog. Writes `status: awaiting_payment`, `total_amount`, `approved_at`,
   `approved_by` directly via the Supabase SDK (`sendPayment` in `lib/store.tsx`).
2. **Decline** — owner may add a note. Writes `status: declined`, optionally
   `notes`, `approved_at`, `approved_by` directly via the SDK
   (`declineRequest` in `lib/store.tsx`).

**DEMO SIMPLIFICATION** — the original design routed both actions through an
n8n webhook (WF-2, `https://n8n.srv1766517.hstgr.cloud/webhook/wf2`) which
created a QuickBooks invoice, a `booking.payments` row, a MobiPaid payment
link, emailed the customer, and wrote the status itself, with the dashboard
only reflecting the result via Realtime. This demo has no n8n/QuickBooks/
MobiPaid running, so the dashboard now writes `status` directly instead — no
invoice, payment link, or email is actually sent. `awaiting_payment` → `confirmed`
does **not** happen automatically in this demo (there's no payment provider to
confirm it); the owner would need a manual "mark confirmed" action to close
that loop, which does not currently exist. Restoring the real n8n integration
for production means reverting `sendPayment`/`declineRequest` to POST to WF-2
again instead of writing `booking.requests` directly.

WF-1 (request intake) is now the website inserting straight into
`booking.requests` via the `booking.create_booking_request()` RPC (see
`supabase/migrations/0001_init_schema.sql`) rather than an n8n-mediated
intake. WF-4 (reminders, cron-based) does not exist in this demo.

## The store seam (key architectural decision)
ALL state mutations live in `lib/store.tsx` (`sendPayment`, `declineRequest`,
`cancelRequest`, `markCompleted`). Components are presentational and call
these actions — they never touch Supabase or n8n directly. This is the single
seam where data access changes.

## Payments (`booking.payments`)
One row per payment attempt, linked via `request_id`. Includes
`quickbooks_invoice_id` / `quickbooks_customer_id` / `quickbooks_payment_id`
for reconciliation — surfaced as a small reference on the request detail page
when present. The dashboard reads this table directly (read-only,
`fetchPaymentForRequest` in the store); it never writes to it — n8n does.

## What is out of scope here
- No PWA / manifest / service worker
- No real payment provider, QuickBooks, or email sending — approve/decline
  only flip `status` in Supabase (see DEMO SIMPLIFICATION above)
- No "mark confirmed" action — `awaiting_payment` requests stay there unless
  seeded otherwise, since nothing in this demo confirms payment automatically
