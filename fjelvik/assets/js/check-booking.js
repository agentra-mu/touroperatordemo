// check-booking.html: looks up a booking by reference + email via the
// booking.lookup_booking() RPC — the only read path the public anon key has
// into booking.requests, so customers can't browse each other's bookings.
import { getSupabase } from "./supabase-client.js";

const STATUS_LABELS = {
  pending_review: "Pending review",
  declined: "Declined",
  approved: "Approved",
  awaiting_payment: "Awaiting payment",
  confirmed: "Confirmed",
  reminded: "Reminded",
  completed: "Completed",
  cancelled: "Cancelled",
};

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
  }[c]));
}

function formatPrice(amount, currency) {
  if (amount === null || amount === undefined) return "Not set yet";
  return `${currency === "MUR" ? "Rs" : currency} ${Number(amount).toLocaleString("en-US")}`;
}

document.addEventListener("DOMContentLoaded", () => {
  const form = document.querySelector("[data-lookup-form]");
  const result = document.querySelector("[data-lookup-result]");
  if (!form || !result) return;

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const reference = form.querySelector("#lk-reference").value.trim();
    const email = form.querySelector("#lk-email").value.trim();
    const button = form.querySelector('button[type="submit"]');

    button.disabled = true;
    button.textContent = "Checking…";
    result.hidden = true;

    try {
      const { data, error } = await getSupabase().rpc("lookup_booking", {
        p_reference: reference,
        p_email: email,
      });
      if (error) throw error;

      const row = Array.isArray(data) ? data[0] : data;
      if (!row) {
        result.innerHTML = `<p class="empty">No booking found for that reference and email. Double check both and try again.</p>`;
      } else {
        const dates = row.end_date && row.end_date !== row.start_date
          ? `${row.start_date} → ${row.end_date}`
          : row.start_date;
        result.innerHTML = `
          <div class="bookcard" style="max-width:520px">
            <p class="bookcard__price">${escapeHtml(row.activity_name)}</p>
            <p><span class="label">Reference</span> ${escapeHtml(row.reference)}</p>
            <p><span class="label">Status</span> <strong>${escapeHtml(STATUS_LABELS[row.status] || row.status)}</strong></p>
            <p><span class="label">Date</span> ${escapeHtml(dates)}</p>
            <p><span class="label">Party size</span> ${row.party_size}</p>
            <p><span class="label">Total</span> ${formatPrice(row.total_amount, row.currency)}${row.total_amount !== null ? (row.paid ? " · Paid" : " · Not paid yet") : ""}</p>
            ${row.status === "declined" && row.notes ? `<p><span class="label">Note</span> ${escapeHtml(row.notes)}</p>` : ""}
          </div>`;
      }
      result.hidden = false;
    } catch (err) {
      console.error("Lookup failed:", err);
      result.innerHTML = `<p class="empty">Something went wrong: ${escapeHtml(err.message || "unknown error")}</p>`;
      result.hidden = false;
    } finally {
      button.disabled = false;
      button.textContent = "Check status";
    }
  });
});
