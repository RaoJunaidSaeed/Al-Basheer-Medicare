export function calculateOutstandingBalance(
  charges: number,
  payments: number,
  credits = 0,
): number {
  const balance = charges - payments - credits;
  return Math.max(0, Math.round(balance));
}

export function normalizeWhatsAppNumber(phone: string, defaultCountryCode = "92"): string {
  const digits = phone.replace(/\D/g, "");
  if (digits.startsWith(defaultCountryCode)) return digits;
  if (digits.startsWith("0")) return `${defaultCountryCode}${digits.slice(1)}`;
  return digits;
}

export function buildBalanceMessage(input: {
  name: string;
  balance: number;
  accountId: string;
  lastUpdate: string;
}): string {
  const amount = input.balance.toLocaleString("en-PK");
  return `Assalam-o-Alaikum ${input.name}. Aap ka Hospital Pharmacy account update:\n\nCurrent Udhaar: Rs. ${amount}\nLast update: ${input.lastUpdate}\nAccount No: ${input.accountId}\n\nKisi correction ke liye pharmacy se rabta karein.`;
}
