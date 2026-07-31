# Splits a payment across a set of CreditEntryItems proportionally to each
# item's remaining balance. The last outstanding item absorbs any rounding
# remainder so the total always reconciles exactly.
#
# Ported from allocatePaymentToItems (context/CreditLedgerContext.tsx) on the
# mobile app. Used both by CreditPayments::RecordCustomerPayment (paying down
# an existing entry) and, later, by the credit-entry-creation flow (an
# upfront deposit taken when a single new entry is created) — mirroring the
# two call sites the TS version has today.
#
# Pure with respect to persistence: it mutates and returns the in-memory
# item objects (amount_paid / balance) but never saves them. Callers decide
# when/whether to persist, typically inside their own transaction.
class CreditEntryItemAllocator
  def self.call(items:, pay_amount:)
    items = items.to_a
    return items if items.empty?

    pay_amount = BigDecimal(pay_amount.to_s)

    items.each do |item|
      item.balance = item.balance.nil? ? item.total : item.balance
      item.amount_paid = item.amount_paid || 0
    end

    total_outstanding = items.sum { |item| item.balance }
    return items if total_outstanding <= 0

    remaining = pay_amount
    outstanding_indices = items.each_index.select { |idx| items[idx].balance > 0 }
    last_outstanding_index = outstanding_indices.last

    items.each_with_index do |item, idx|
      next if item.balance <= 0

      share = item.balance / total_outstanding
      item_payment =
        if idx == last_outstanding_index
          remaining
        else
          [pay_amount * share, item.balance].min
        end
      item_payment = [[item_payment, 0].max, item.balance].min

      remaining -= item_payment
      item.amount_paid += item_payment
      item.balance = [item.balance - item_payment, 0].max
    end

    items
  end
end
