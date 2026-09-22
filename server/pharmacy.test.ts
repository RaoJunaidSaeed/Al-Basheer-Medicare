import { describe, expect, it } from "vitest";
import {
  buildBalanceMessage,
  calculateOutstandingBalance,
  normalizeWhatsAppNumber,
} from "../shared/pharmacy";

describe("pharmacy ledger helpers", () => {
  it("calculates an outstanding balance without allowing a negative khata", () => {
    expect(calculateOutstandingBalance(10000, 3500, 500)).toBe(6000);
    expect(calculateOutstandingBalance(10000, 12000)).toBe(0);
  });

  it("normalizes Pakistani phone numbers for WhatsApp links", () => {
    expect(normalizeWhatsAppNumber("0300 1234567")).toBe("923001234567");
    expect(normalizeWhatsAppNumber("+92 300 1234567")).toBe("923001234567");
  });

  it("creates a concise patient balance message", () => {
    const message = buildBalanceMessage({
      name: "Ayesha Khan",
      balance: 12400,
      accountId: "PT-1024",
      lastUpdate: "Today, 10:42 AM",
    });

    expect(message).toContain("Ayesha Khan");
    expect(message).toContain("Rs. 12,400");
    expect(message).toContain("PT-1024");
    expect(message).not.toContain("diagnosis");
  });
});
