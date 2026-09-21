// Renders tour cards from Supabase into any [data-tour-grid] on the page
// (tours.html's full grid, index.html's featured strip) and wires the
// existing filter/sort behaviour in main.js back up afterwards, since that
// code expects the cards to already be in the DOM at page load.
import { fetchTours, CATEGORY_LABELS, formatPrice } from "./tours-data.js";

const PLACE_ICON =
  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 21s-7-6.2-7-11.5a7 7 0 0 1 14 0C19 14.8 12 21 12 21Z"/><circle cx="12" cy="9.5" r="2.5"/></svg>';
const CLOCK_ICON =
  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>';
const GO_ICON =
  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 17 17 7M8 7h9v9"/></svg>';

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
  }[c]));
}

export function tourCardHtml(tour) {
  const place = tour.location ? `<p class="tcard__place">${PLACE_ICON}${escapeHtml(tour.location)}</p>` : "";
  return `
    <article class="tcard" data-kind="${escapeHtml(tour.category)}" data-price="${tour.price}">
      <div class="tcard__media">
        <img src="${escapeHtml(tour.image_url)}" alt="${escapeHtml(tour.title)}" width="800" height="600" loading="lazy" decoding="async" />
        <span class="tcard__kind">${escapeHtml(CATEGORY_LABELS[tour.category] || tour.category)}</span>
      </div>
      <div class="tcard__body">
        ${place}
        <h3 class="tcard__name"><a href="tour.html?slug=${encodeURIComponent(tour.slug)}">${escapeHtml(tour.title)}</a></h3>
        <p class="tcard__facts">
          <span>${CLOCK_ICON}${escapeHtml(tour.duration_label)}</span>
        </p>
        <p class="tcard__foot">
          <span class="tcard__price"><small>from</small> ${formatPrice(tour.price, tour.currency)}</span>
          <span class="tcard__go" aria-hidden="true">${GO_ICON}</span>
        </p>
      </div>
    </article>`;
}

export async function renderTourGrid(root, { limit } = {}) {
  if (!root) return [];
  try {
    let tours = await fetchTours();
    if (limit) tours = tours.slice(0, limit);
    root.innerHTML = tours.map(tourCardHtml).join("");
    return tours;
  } catch (err) {
    console.error("Failed to load tours:", err);
    root.innerHTML = `<p class="empty" style="grid-column:1/-1">Could not load tours right now. ${escapeHtml(err.message || "")}</p>`;
    return [];
  }
}

async function boot() {
  const grid = document.querySelector("[data-tour-grid]");
  const featured = document.querySelector("[data-featured-tours]");

  if (grid) {
    const countLabel = document.querySelector("[data-tour-count-label]");
    const tours = await renderTourGrid(grid);
    if (countLabel) countLabel.textContent = `${tours.length} guided tours & activities`;
    window.__fjelvikInitTourFilters?.();
  }

  if (featured) {
    await renderTourGrid(featured, { limit: 3 });
  }
}

boot();
