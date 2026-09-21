-- Allez Moris / Fjelvik demo — seed / reset data.
-- Re-run this any time to reset the demo back to a clean starting point
-- (e.g. before a new client meeting). It wipes and re-creates the tours
-- catalog and a handful of sample requests spanning every status the
-- dashboard understands.
--
-- Run in the Supabase SQL Editor, or: supabase db execute -f supabase/seed.sql

begin;

truncate table booking.payments restart identity cascade;
truncate table booking.requests restart identity cascade;
truncate table booking.tours restart identity cascade;

-- ---------------------------------------------------------------------------
-- Tours catalog (15 tours). This is the single place to edit the catalog —
-- both the website and the dashboard read straight from this table.
-- ---------------------------------------------------------------------------
insert into booking.tours
  (slug, title, category, form_type, location, short_description, description,
   price, currency, duration_label, image_url, gallery, highlights, max_party_size)
values
  (
    'catamaran-sunset-cruise', 'Catamaran Sunset Cruise', 'water', 'activity',
    'Grand Baie', 'Sail the lagoon at golden hour with drinks and a BBQ dinner on board.',
    'Board a private catamaran for a relaxed afternoon sail along the north coast lagoon, anchoring for a swim and snorkel stop before drinks and a barbecue dinner are served on deck as the sun goes down. A local crew handles the sailing so you can just enjoy the ride.',
    4500, 'MUR', 'Half day (4 hrs)',
    'https://images.pexels.com/photos/1010141/pexels-photo-1010141.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/1010141/pexels-photo-1010141.jpeg?auto=compress&cs=tinysrgb&w=1200","https://images.pexels.com/photos/1533720/pexels-photo-1533720.jpeg?auto=compress&cs=tinysrgb&w=1200","https://images.pexels.com/photos/1174732/pexels-photo-1174732.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Open bar on board","Snorkel stop over a coral reef","BBQ dinner included","Small groups only"]', 20
  ),
  (
    'le-morne-hiking-trail', 'Le Morne Hiking Trail', 'nature', 'activity',
    'Le Morne', 'Guided hike up the UNESCO-listed Le Morne Brabant peak.',
    'A guided half-day trek to the summit of Le Morne Brabant, the basalt monolith at the island''s south-west tip and a UNESCO World Heritage Site. The trail climbs through dry forest before opening onto sweeping views over the lagoon. Moderate fitness required for the final scramble.',
    2200, 'MUR', 'Half day (5 hrs)',
    'https://images.pexels.com/photos/2325446/pexels-photo-2325446.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/2325446/pexels-photo-2325446.jpeg?auto=compress&cs=tinysrgb&w=1200","https://images.pexels.com/photos/1287460/pexels-photo-1287460.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Certified local guide","Water and snacks included","Summit views over the lagoon","Moderate difficulty"]', 12
  ),
  (
    'seaside-villa-trou-aux-biches', 'Seaside Villa — Trou aux Biches', 'accommodation', 'accommodation',
    'Trou aux Biches', 'A 3-bedroom beachfront villa with private pool, steps from the lagoon.',
    'This three-bedroom villa sits a two-minute walk from the calm, shallow lagoon at Trou aux Biches. Expect a private pool, a fully equipped kitchen, daily housekeeping and a shaded outdoor dining terrace — comfortably set up for a family or two couples travelling together.',
    9500, 'MUR', 'Per night',
    'https://images.pexels.com/photos/1732414/pexels-photo-1732414.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/1732414/pexels-photo-1732414.jpeg?auto=compress&cs=tinysrgb&w=1200","https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg?auto=compress&cs=tinysrgb&w=1200","https://images.pexels.com/photos/271816/pexels-photo-271816.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Private pool","3 bedrooms, sleeps 6","Daily housekeeping","2 min walk to the lagoon"]', 6
  ),
  (
    'toyota-rav4', 'Toyota RAV4', 'transport', 'rental',
    'Airport pickup available', 'Automatic mid-size SUV rental, ideal for families exploring the island.',
    'A comfortable automatic SUV with air conditioning and plenty of boot space — a good fit for a family doing its own island touring. Unlimited mileage, full insurance and airport pickup/drop-off included. A child seat can be added on request.',
    1800, 'MUR', 'Per day',
    'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Automatic transmission","Unlimited mileage","Full insurance included","Optional child seat"]', 5
  ),
  (
    'deep-sea-fishing-half-day', 'Deep Sea Fishing Half Day', 'water', 'activity',
    'Black River', 'Half-day big game fishing charter off the west coast.',
    'Head out past the reef in search of marlin, tuna and wahoo aboard a fully equipped sport-fishing boat. The crew handles bait, tackle and the boat while you fish; all catches can be released or kept and prepared for you back on shore.',
    12000, 'MUR', 'Half day (5 hrs)',
    'https://images.pexels.com/photos/1054655/pexels-photo-1054655.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/1054655/pexels-photo-1054655.jpeg?auto=compress&cs=tinysrgb&w=1200","https://images.pexels.com/photos/2144905/pexels-photo-2144905.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Rods, bait and tackle included","Experienced skipper and crew","Catch cleaned and prepared on request","Max 4 anglers per boat"]', 4
  ),
  (
    'ssr-airport-le-morne', 'SSR Airport — Le Morne', 'transport', 'transfer',
    'SSR International Airport', 'Private airport transfer to the Le Morne / south-west coast hotels.',
    'A private, air-conditioned transfer between SSR International Airport and hotels along the Le Morne / south-west coast. The driver tracks your flight and waits for arrivals, so delays are not a problem. Fits up to 7 passengers with luggage.',
    2500, 'MUR', 'One-way (~1 hr)',
    'https://images.pexels.com/photos/1178448/pexels-photo-1178448.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/1178448/pexels-photo-1178448.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Flight tracking included","Meet & greet at arrivals","Up to 7 passengers","Child seats on request"]', 7
  ),
  (
    'quad-biking-adventure', 'Quad Biking Adventure', 'land', 'activity',
    'Domaine Anna, Chamouny', 'Guided quad bike trail through sugarcane fields and forest.',
    'Ride your own automatic quad along a guided trail through sugarcane fields, forest tracks and a river crossing. A briefing and short practice loop are included before the main ride, so no prior experience is needed.',
    3000, 'MUR', 'Half day (3 hrs)',
    'https://images.pexels.com/photos/2549938/pexels-photo-2549938.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/2549938/pexels-photo-2549938.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["No experience needed","Automatic quads","Helmet and gear provided","River crossing included"]', 16
  ),
  (
    'underwater-sea-walk', 'Underwater Sea Walk', 'water', 'activity',
    'Belle Mare', 'Walk the seabed in a diving helmet — no swimming skills required.',
    'Descend a ladder in a pressurised diving helmet and walk along the sandy seabed among coral and reef fish, breathing normally throughout. No swimming ability or diving certification is needed — a guide stays with you the whole time.',
    7000, 'MUR', '2.5 hours',
    'https://images.pexels.com/photos/3894559/pexels-photo-3894559.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/3894559/pexels-photo-3894559.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["No swimming or diving skills needed","Guide accompanies you underwater","Photos available after","Suitable from age 8"]', 10
  ),
  (
    'garden-view-bungalow', 'Garden View Bungalow', 'accommodation', 'accommodation',
    'Flic en Flac', 'A quiet 1-bedroom bungalow set in tropical gardens near the beach.',
    'A self-contained one-bedroom bungalow set back in tropical gardens, a short stroll from Flic en Flac beach. Simple, comfortable and quiet — a good base for a couple who want to spend their days at the beach and restaurants nearby.',
    3000, 'MUR', 'Per night',
    'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&cs=tinysrgb&w=1200","https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Tropical garden setting","5 min walk to the beach","Kitchenette","Free WiFi"]', 2
  ),
  (
    'suzuki-swift', 'Suzuki Swift', 'transport', 'rental',
    'Airport pickup available', 'Compact automatic hatchback, easy on fuel and parking.',
    'A compact, fuel-efficient hatchback that''s easy to park and manoeuvre on the island''s narrower roads — a good economical choice for one or two people covering ground independently. Unlimited mileage and full insurance included.',
    1200, 'MUR', 'Per day',
    'https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Automatic transmission","Unlimited mileage","Full insurance included","Great fuel economy"]', 4
  ),
  (
    'glass-bottom-boat-blue-bay', 'Glass Bottom Boat — Blue Bay', 'water', 'activity',
    'Blue Bay Marine Park', 'View the coral reef and marine park without getting wet.',
    'Glide over the protected coral gardens of Blue Bay Marine Park in a glass-bottomed boat, spotting reef fish, coral formations and the occasional turtle without needing to swim. A relaxed, family-friendly way to see the reef.',
    2000, 'MUR', '1.5 hours',
    'https://images.pexels.com/photos/1078983/pexels-photo-1078983.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/1078983/pexels-photo-1078983.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["No swimming required","Marine park protected reef","Family friendly","Departs every hour"]', 15
  ),
  (
    'zip-line-domaine-de-letoile', 'Zip Line at Domaine de l''Étoile', 'land', 'activity',
    'Domaine de l''Étoile', 'A canopy zip line circuit through native forest above the plains.',
    'A multi-line zip circuit strung through native forest in the highlands, with platforms connected by short forest walks. Suitable for most fitness levels — full safety briefing and equipment included before the first line.',
    4000, 'MUR', '2 hours',
    'https://images.pexels.com/photos/2245436/pexels-photo-2245436.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/2245436/pexels-photo-2245436.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Multiple zip lines","Full safety gear provided","Forest canopy views","Suitable from age 10"]', 12
  ),
  (
    'chamarel-seven-coloured-earth', 'Chamarel & Seven Coloured Earth', 'nature', 'activity',
    'Chamarel', 'Half-day tour to the coloured earth dunes and Chamarel waterfall.',
    'Visit the geological curiosity of the Seven Coloured Earth dunes and the nearby Chamarel waterfall, one of the island''s tallest, before a stop at a local rum distillery for tasting. A relaxed, mostly-walking half-day suited to all ages.',
    2800, 'MUR', 'Half day (4 hrs)',
    'https://images.pexels.com/photos/6272397/pexels-photo-6272397.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/6272397/pexels-photo-6272397.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Rum tasting included","Suitable for all ages","Chamarel waterfall viewpoint","Air-conditioned transport"]', 14
  ),
  (
    'ile-aux-cerfs-day-trip', 'Île aux Cerfs Island Day Trip', 'water', 'activity',
    'Trou d''Eau Douce', 'A full day on the island''s most popular islet — beach, lunch and water sports.',
    'A speedboat transfer out to Île aux Cerfs for a full day on one of the island''s best beaches, with a buffet lunch included and optional water sports (jet ski, parasailing, banana boat) available on-site at your own pace.',
    3500, 'MUR', 'Full day (7 hrs)',
    'https://images.pexels.com/photos/1450353/pexels-photo-1450353.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/1450353/pexels-photo-1450353.jpeg?auto=compress&cs=tinysrgb&w=1200","https://images.pexels.com/photos/1078983/pexels-photo-1078983.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Speedboat transfer both ways","Buffet lunch included","Optional water sports on-site","Full day on the beach"]', 20
  ),
  (
    'black-river-gorges-trek', 'Black River Gorges Trek', 'nature', 'activity',
    'Black River Gorges National Park', 'Rainforest trekking through the island''s largest national park.',
    'A guided trek through Black River Gorges National Park''s native rainforest, passing waterfall viewpoints and lookouts over the gorges. Trails are uneven underfoot in places — sturdy footwear recommended.',
    2400, 'MUR', 'Half day (4 hrs)',
    'https://images.pexels.com/photos/1287460/pexels-photo-1287460.jpeg?auto=compress&cs=tinysrgb&w=1200',
    '["https://images.pexels.com/photos/1287460/pexels-photo-1287460.jpeg?auto=compress&cs=tinysrgb&w=1200"]',
    '["Native rainforest trail","Waterfall viewpoints","Certified guide","Moderate difficulty"]', 12
  );

-- ---------------------------------------------------------------------------
-- Sample requests spanning every status, so the dashboard has something to
-- show on first load. Uses booking.create_booking_request() where the shape
-- matches, then updates status directly to simulate review having happened.
-- ---------------------------------------------------------------------------
do $$
declare
  v_id uuid;
begin
  -- pending_review
  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, party_size, message, form_type, status)
  select id, slug, title, 'Jean-Pierre Dupont', 'jp.dupont@email.com', '+230 5912 3456', 4, 0, '2026-07-15', 4, 'Anniversary celebration. Can we get champagne on board?', form_type, 'pending_review'
  from booking.tours where slug = 'catamaran-sunset-cruise';

  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, party_size, message, form_type, status)
  select id, slug, title, 'Sarah Chen', 'sarah.c@gmail.com', '+852 9123 4567', 2, 0, '2026-07-22', 2, 'Are hiking boots required or can we wear trainers?', form_type, 'pending_review'
  from booking.tours where slug = 'le-morne-hiking-trail';

  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, end_date, party_size, message, form_type, status)
  select id, slug, title, 'Raj Patel', 'raj.p@outlook.com', '+230 5789 0123', 4, 2, '2026-08-05', '2026-08-12', 6, 'Family with two young children (ages 5 and 8). Need a crib.', form_type, 'pending_review'
  from booking.tours where slug = 'seaside-villa-trou-aux-biches';

  -- approved (no price set yet)
  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, end_date, party_size, message, form_type, status, approved_at, approved_by)
  select id, slug, title, 'Marie Leblanc', 'marie.lb@free.fr', '+33 6 12 34 56 78', 3, 0, '2026-07-10', '2026-07-17', 3, 'Need a child seat option if available.', form_type, 'approved', now() - interval '2 days', 'owner@example.com'
  from booking.tours where slug = 'toyota-rav4';

  -- awaiting_payment
  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, party_size, message, form_type, status, total_amount, approved_at, approved_by)
  select id, slug, title, 'Tom Williams', 'tom.w@yahoo.co.uk', '+44 7700 900123', 2, 0, '2026-07-18', 2, '', form_type, 'awaiting_payment', 12000, now() - interval '1 day', 'owner@example.com'
  from booking.tours where slug = 'deep-sea-fishing-half-day';

  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, party_size, message, form_type, status, total_amount, approved_at, approved_by)
  select id, slug, title, 'Aisha Mohammed', 'aisha.m@gmail.com', '+971 50 123 4567', 5, 0, '2026-07-25', 5, 'Flight MK042 arriving 14:35. Need a 7-seater.', form_type, 'awaiting_payment', 10000, now() - interval '1 day', 'owner@example.com'
  from booking.tours where slug = 'ssr-airport-le-morne';

  -- confirmed (paid)
  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, party_size, message, form_type, status, total_amount, paid, approved_at, approved_by)
  select id, slug, title, 'Lucas Martin', 'lucas.martin@web.de', '+49 170 1234567', 4, 0, '2026-07-20', 4, 'All adults. Looking forward to it!', form_type, 'confirmed', 12000, true, now() - interval '5 days', 'owner@example.com'
  from booking.tours where slug = 'quad-biking-adventure';

  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, party_size, message, form_type, status, total_amount, paid, approved_at, approved_by)
  select id, slug, title, 'Yuki Tanaka', 'yuki.t@icloud.com', '+81 90 1234 5678', 2, 0, '2026-07-08', 2, 'First time — quite nervous but excited!', form_type, 'confirmed', 7000, true, now() - interval '6 days', 'owner@example.com'
  from booking.tours where slug = 'underwater-sea-walk';

  -- completed
  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, end_date, party_size, message, form_type, status, total_amount, paid, approved_at, approved_by)
  select id, slug, title, 'Elena Rossi', 'elena.r@tin.it', '+39 333 1234567', 2, 0, '2026-06-15', '2026-06-20', 2, 'Wonderful experience, thank you!', form_type, 'completed', 3000, true, now() - interval '20 days', 'owner@example.com'
  from booking.tours where slug = 'garden-view-bungalow';

  -- declined
  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, end_date, party_size, message, form_type, status, notes, approved_by)
  select id, slug, title, 'Mike Johnson', 'mike.j@aol.com', '+1 555 0123', 1, 0, '2026-07-01', '2026-07-05', 1, 'Wanted to go solo.', form_type, 'declined', 'No vehicles available for those dates.', 'owner@example.com'
  from booking.tours where slug = 'suzuki-swift';

  -- cancelled
  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, party_size, message, form_type, status, total_amount, paid, approved_at, approved_by)
  select id, slug, title, 'Priya Sharma', 'priya.s@rediffmail.com', '+91 98765 43210', 3, 0, '2026-06-28', 3, 'Trip cancelled due to weather concerns.', form_type, 'cancelled', 6000, true, now() - interval '10 days', 'owner@example.com'
  from booking.tours where slug = 'glass-bottom-boat-blue-bay';

  -- reminded
  insert into booking.requests (tour_id, activity_ref, activity_name, full_name, email, phone, adults, children, start_date, party_size, message, form_type, status, total_amount, paid, approved_at, approved_by)
  select id, slug, title, 'Anna Kowalski', 'anna.k@wp.pl', '+48 600 123 456', 4, 0, '2026-07-12', 4, 'Reminder sent for upcoming activity.', form_type, 'reminded', 12000, true, now() - interval '15 days', 'owner@example.com'
  from booking.tours where slug = 'zip-line-domaine-de-letoile';
end $$;

commit;
