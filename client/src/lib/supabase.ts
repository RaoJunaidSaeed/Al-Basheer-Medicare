import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const supabaseKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY as string | undefined;

export const supabaseConfigMissing = !supabaseUrl || !supabaseKey;

export const supabase = supabaseConfigMissing
  ? null
  : createClient(supabaseUrl!, supabaseKey!, {
      realtime: { params: { eventsPerSecond: 10 } },
    });

export type DbPatient = {
  id: string;
  name: string;
  phone: string;
  area: string;
  category: string;
  created_at: string;
  updated_at: string;
};

export type DbTransaction = {
  id: string;
  patient_id: string;
  type: "Credit sale" | "Payment received" | "Return";
  detail: string;
  total: number | string;
  paid: number | string;
  due: number | string;
  method: string | null;
  transaction_date: string;
  created_at: string;
  updated_at: string;
};

export async function loadSupabaseData() {
  if (!supabase) throw new Error("Supabase is not configured. Add VITE_SUPABASE_URL and VITE_SUPABASE_PUBLISHABLE_KEY.");
  const [{ data: patientRows, error: patientError }, { data: transactionRows, error: transactionError }] = await Promise.all([
    supabase.from("patients").select("*").order("created_at", { ascending: false }),
    supabase.from("transactions").select("*").order("transaction_date", { ascending: false }),
  ]);
  if (patientError) throw patientError;
  if (transactionError) throw transactionError;
  return { patients: (patientRows ?? []) as DbPatient[], transactions: (transactionRows ?? []) as DbTransaction[] };
}
