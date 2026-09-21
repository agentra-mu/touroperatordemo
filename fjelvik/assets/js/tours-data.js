// Reads from the same booking.tours table the dashboard reads from — see
// supabase/seed.sql for the single source of truth for catalog content.
import { getSupabase } from "./supabase-client.js";

export const CATEGORY_LABELS = {
  water: "Water Activities",
  land: "Land Adventure",
  nature: "Nature & Hiking",
  accommodation: "Accommodation",
  transport: "Transport",
};

let cache = null;

export async function fetchTours() {
  if (cache) return cache;
  const { data, error } = await getSupabase()
    .from("tours")
    .select("*")
    .eq("is_active", true)
    .order("title");
  if (error) throw error;
  cache = data ?? [];
  return cache;
}

export async function fetchTourBySlug(slug) {
  const { data, error } = await getSupabase()
    .from("tours")
    .select("*")
    .eq("slug", slug)
    .eq("is_active", true)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export function formatPrice(price, currency) {
  const amount = Number(price).toLocaleString("en-US");
  return `${currency === "MUR" ? "Rs" : currency} ${amount}`;
}
