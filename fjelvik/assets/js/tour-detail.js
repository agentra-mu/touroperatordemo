// tour.html: loads the tour named by ?slug=... from Supabase, fills in the
// page, and wires the booking form to insert a real request via the
// booking.create_booking_request() RPC.
import { fetchTourBySlug, fetchTours, CATEGORY_LABELS, formatPrice } from "./tours-data.js";
import { getSupabase } from "./supabase-client.js";
import { tourCardHtml } from "./catalog.js";

const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
  }[c]));
}

function renderNotFound() {
  const main = $("#main");
  if (main) {
    main.innerHTML = `
      <section class="container section">
        <h1>Tour not found</h1>
        <p>That tour doesn't exist or is no longer available.</p>
        <p><a class="btn btn--dark" href="tours.html">Back to all tours</a></p>
      </section>`;
  }
}

function fillHero(tour) {
  document.title = `${tour.title} — Fjelvik`;
  const heroImg = $(".thero__img");
  if (heroImg) {
    heroImg.src = tour.image_url;
    heroImg.alt = tour.title;
  }
  const crumb = $(".crumbs span[aria-current]");
  if (crumb) crumb.textContent = tour.title;
  const h1 = $("#tour-title");
  if (h1) h1.textContent = tour.title;

  const facts = $(".thero__facts");
  if (facts) {
    facts.innerHTML = `
      <li><span class="label">Duration</span>${escapeHtml(tour.duration_label)}</li>
      <li><span class="label">Category</span>${escapeHtml(CATEGORY_LABELS[tour.category] || tour.category)}</li>
      ${tour.location ? `<li><span class="label">Location</span>${escapeHtml(tour.location)}</li>` : ""}
      <li><span class="label">Group size</span>Max ${tour.max_party_size}</li>
    `;
  }
}

function fillGallery(tour) {
  const gallery = (tour.gallery && tour.gallery.length ? tour.gallery : [tour.image_url]);
  const stage = $("[data-gallery-stage]");
  const thumbsWrap = $(".gallery__thumbs");
  if (stage) {
    stage.src = gallery[0];
    stage.alt = tour.title;
  }
  if (thumbsWrap) {
    thumbsWrap.innerHTML = gallery.map((url, i) => `
      <button type="button" data-gallery-thumb aria-pressed="${i === 0}" data-full="${escapeHtml(url)}" data-alt="${escapeHtml(tour.title)}" aria-label="Photo ${i + 1}">
        <img src="${escapeHtml(url)}" alt="" width="300" height="200" loading="lazy" />
      </button>`).join("");
  }
}

function fillProse(tour) {
  const prose = $(".prose");
  if (prose) {
    prose.innerHTML = `<h2>About this tour</h2><p>${escapeHtml(tour.description)}</p>`;
  }
  const includes = $(".includes");
  const highlights = Array.isArray(tour.highlights) ? tour.highlights : [];
  if (includes) {
    if (!$(".includes-heading")) {
      includes.insertAdjacentHTML("beforebegin", '<h2 class="includes-heading">Highlights</h2>');
    }
    includes.innerHTML = highlights.map((h) => `<li>${escapeHtml(h)}</li>`).join("");
  }
  // Turn the itinerary/accordion section into a simple "Good to know" block —
  // there's no multi-day itinerary for a single activity/rental/stay.
  const itinerary = $(".itinerary");
  if (itinerary) {
    itinerary.innerHTML = `
      <h2>Good to know</h2>
      <div class="acc" data-accordion>
        <h3><button class="acc__btn" type="button" aria-expanded="true" aria-controls="gtk-1"><span class="label">Booking</span>How this works</button></h3>
        <div class="acc__panel" id="gtk-1"><p>Submit the form to send a request — nothing is charged today. We'll review it and follow up by email with confirmation and a price if it isn't already set.</p></div>
        <h3><button class="acc__btn" type="button" aria-expanded="false" aria-controls="gtk-2"><span class="label">Status</span>Checking your booking</button></h3>
        <div class="acc__panel" id="gtk-2" hidden><p>Use the reference code we email you and your <a href="check-booking.html">booking lookup page</a> to check the status any time.</p></div>
      </div>`;
    window.__fjelvikInitAccordions?.();
  }
}

function fillBookingCard(tour) {
  const price = $(".bookcard__price");
  if (price) price.innerHTML = `${formatPrice(tour.price, tour.currency)} <small>${escapeHtml(tour.duration_label)}</small>`;

  const form = $(".bookcard");
  if (!form) return;

  const isRange = tour.form_type === "accommodation" || tour.form_type === "rental";
  const dateField = $("#bk-date", form)?.closest(".field");
  if (dateField) {
    dateField.innerHTML = isRange
      ? `<label class="field__label" for="bk-start">${tour.form_type === "rental" ? "Pick-up date" : "Check-in"}</label>
         <span class="input"><input id="bk-start" type="date" required /></span>
         <label class="field__label" for="bk-end" style="margin-top:.6rem">${tour.form_type === "rental" ? "Drop-off date" : "Check-out"}</label>
         <span class="input"><input id="bk-end" type="date" required /></span>`
      : `<label class="field__label" for="bk-start">Date</label>
         <span class="input"><input id="bk-start" type="date" required /></span>`;
  }

  const peopleSelect = $("#bk-people", form);
  if (peopleSelect) {
    const max = Math.min(tour.max_party_size, 10);
    peopleSelect.innerHTML = Array.from({ length: max }, (_, i) => i + 1)
      .map((n) => `<option value="${n}"${n === 2 ? " selected" : ""}>${n} ${n === 1 ? "traveller" : "travellers"}</option>`)
      .join("");
  }

  // Add name/phone/message fields ahead of email if not already present.
  const emailField = $("#bk-email", form)?.closest(".field");
  if (emailField && !$("#bk-name", form)) {
    emailField.insertAdjacentHTML("beforebegin", `
      <div class="field">
        <label class="field__label" for="bk-name">Full name</label>
        <span class="input"><input id="bk-name" type="text" autocomplete="name" required /></span>
      </div>`);
  }
  if (emailField && !$("#bk-phone", form)) {
    emailField.insertAdjacentHTML("afterend", `
      <div class="field">
        <label class="field__label" for="bk-phone">Phone</label>
        <span class="input"><input id="bk-phone" type="tel" autocomplete="tel" /></span>
      </div>
      <div class="field">
        <label class="field__label" for="bk-message">Message (optional)</label>
        <span class="input"><textarea id="bk-message" rows="2"></textarea></span>
      </div>`);
  }

  const submitBtn = $('button[type="submit"]', form);
  const note = $(".form-note", form);

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const invalid = $$("input, select, textarea", form).filter((f) => !f.checkValidity());
    $$(".is-invalid", form).forEach((f) => f.classList.remove("is-invalid"));
    if (invalid.length) {
      invalid.forEach((f) => { f.classList.add("is-invalid"); f.setAttribute("aria-invalid", "true"); });
      invalid[0].focus();
      if (note) note.textContent = "Please check the highlighted fields.";
      return;
    }

    const startDate = $("#bk-start", form).value;
    const endDate = isRange ? $("#bk-end", form).value : null;
    const totalPeople = Number($("#bk-people", form).value || 1);

    if (submitBtn) { submitBtn.disabled = true; submitBtn.textContent = "Sending…"; }
    if (note) note.textContent = "";

    try {
      const { data, error } = await getSupabase().rpc("create_booking_request", {
        p_tour_slug: tour.slug,
        p_full_name: $("#bk-name", form).value.trim(),
        p_email: $("#bk-email", form).value.trim(),
        p_phone: $("#bk-phone", form)?.value.trim() || null,
        p_adults: totalPeople,
        p_children: 0,
        p_start_date: startDate,
        p_end_date: endDate || null,
        p_message: $("#bk-message", form)?.value.trim() || "",
      });
      if (error) throw error;

      const reference = Array.isArray(data) ? data[0]?.reference : data?.reference;
      form.reset();
      form.innerHTML = `
        <p class="bookcard__price">Request sent</p>
        <p>Thanks — your booking request is in. We'll review it and email you.</p>
        <p><strong>Reference: ${escapeHtml(reference || "—")}</strong></p>
        <p class="bookcard__fine">Save this reference and the email you used — you can check the status any time on our <a href="check-booking.html">booking lookup page</a>.</p>`;
    } catch (err) {
      console.error("Booking request failed:", err);
      if (note) note.textContent = `Could not send your request: ${err.message || "unknown error"}. Please try again.`;
      if (submitBtn) { submitBtn.disabled = false; submitBtn.textContent = "Request to book"; }
    }
  });
}

async function fillRelated(tour) {
  const grid = $(".tgrid:not([data-tour-grid])");
  if (!grid) return;
  try {
    const all = await fetchTours();
    const related = all.filter((t) => t.slug !== tour.slug && t.category === tour.category).slice(0, 3);
    const fallback = related.length ? related : all.filter((t) => t.slug !== tour.slug).slice(0, 3);
    grid.innerHTML = fallback.map(tourCardHtml).join("");
  } catch (err) {
    console.error("Failed to load related tours:", err);
  }
}

async function boot() {
  const slug = new URLSearchParams(location.search).get("slug");
  if (!slug) {
    renderNotFound();
    return;
  }
  let tour;
  try {
    tour = await fetchTourBySlug(slug);
  } catch (err) {
    console.error("Failed to load tour:", err);
    renderNotFound();
    return;
  }
  if (!tour) {
    renderNotFound();
    return;
  }
  fillHero(tour);
  fillGallery(tour);
  fillProse(tour);
  fillBookingCard(tour);
  window.__fjelvikInitGallery?.();
  fillRelated(tour);
}

boot();
