# Fjelvik — Travel & Tour Agency HTML Template

Free, static travel agency template from [html.design](https://html.design/).
Six pages, three stylesheets, one vanilla script. No framework, no build step, no dependencies.

## Pages

- `index.html` — photo hero with a working booking panel (Tour / Flight / Hotels tabs, dates, guest stepper), headline with inline photo pills, photo + stat ledger, destination bento, three promises, featured tours, traveller quote over a photograph, closing call to action
- `tours.html` — filterable tour grid (trip type chips, max-price slider, sort), live result count, empty state, destinations strip
- `tour.html` — tour detail: photo hero with key facts, gallery with thumbnails, inclusions, day-by-day accordion, sticky booking card, related tours
- `about.html` — story, figures bento, three working rules, guides
- `contact.html` — enquiry form with validation, office card, FAQ accordion
- `404.html`

## Files

- `assets/css/tokens.css` — every colour, font, size, radius and shadow, plus reset, buttons and fields
- `assets/css/site.css` — header, mobile menu, footer, section heads, destination tiles, tour cards, chips, toast
- `assets/css/pages.css` — page sections
- `assets/js/main.js` — header state, menu, booking tabs, stepper, tour filters, accordion, gallery, form validation, scroll reveal
- `assets/img/CREDITS.md` — photography sources

## Design

- **Layout:** modelled on a Dribbble travel-agency shot — full-bleed photo hero with a floating booking panel, a sentence broken by photo pills, split photo with a stat ledger, then an asymmetric destination bento.
- **Palette:** cool fog `#F3F4F1` ground, pine-black ink `#101412`, and one colour — pale glacier `#D5E4E1` — used as a field (call-to-action pill, chips, closing card) rather than as a bright accent. The photography carries the colour.
- **Type:** SUSE (display), Golos Text (body), Ubuntu Sans Mono (labels).

## Customising

- Change the palette in the first block of `tokens.css`; every component reads from those tokens.
- Tour cards carry `data-kind`, `data-price` and `data-days`; the filters and sort on `tours.html` read those attributes, so adding a tour means adding one card.
- Booking, enquiry and newsletter forms validate and then show a demo message — connect them to your booking engine or form handler.
- Images hot-link from Pexels. Replace them with your own before launch.

## Accessibility

Semantic landmarks, skip link, one `h1` per page, labelled fields, ARIA tabs with arrow-key support, `aria-expanded` accordions, `aria-pressed` chips, Escape closes the mobile menu and returns focus, visible focus rings, and `prefers-reduced-motion` honoured.

## Name check (informal — not a legal opinion)

TM check (informal): "Fjelvik", 2026-09-14
- Web search: no company, product or brand using the name; only people with the surname "Fjellvik" (different spelling)
- Domain: fjelvik.com and fjelvik.co do not resolve
- Rejected: Tarnvale (Tarnvale Estates Ltd registered, domain owned), Wayfell (domain owned), Farhollow (domain owned, game title)
- Verdict: ok to ship

## License

Free for personal and commercial use. Photos under the Pexels License.
