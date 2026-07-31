# Applies a payment across a customer's active credit entries, oldest first
# (FIFO by created_at), delegating the proportional item-level split within
# each entry to CreditEntryItemAllocator.
#
# Ported from recordPayment (context/CreditLedgerContext.tsx) on the mobile
# app. That function is the actual "allocatePaymentToItems" call site for
# repayments — allocatePaymentToItems alone only ever handles a single
# entry's items, never the FIFO-across-entries part.
#
# Returns a Result with the entries that received a payment and any excess
# left over once every active entry has been paid off (e.g. a customer pays
# more than they owe in total) — callers use `excess` to drive the
# overpayment messaging (buildExcessPaymentMessages on the mobile app).
module CreditPayments
  class RecordCustomerPayment
    Result = Struct.new(:paid_entries, :excess, keyword_init: true)

    def self.call(customer:, amount:)
      amount = BigDecimal(amount.to_s)
      raise ArgumentError, "amount must be positive" if amount <= 0

      remaining = amount
      paid_entries = []

      ActiveRecord::Base.transaction do
        active_entries = customer.credit_entries.where(status: "active").order(:created_at)

        active_entries.each do |entry|
          break if remaining <= 0

          pay_for_entry = [remaining, entry.balance].min
          next if pay_for_entry <= 0

          items = entry.credit_entry_items.order(:created_at)
          CreditEntryItemAllocator.call(items: items, pay_amount: pay_for_entry).each(&:save!)

          entry.amount_paid += pay_for_entry
          entry.balance = [entry.balance - pay_for_entry, 0].max
          entry.status = entry.balance <= 0.01 ? "paid" : "active"
          entry.save!

          paid_entries << entry
          remaining -= pay_for_entry
        end
      end

      Result.new(paid_entries: paid_entries, excess: remaining)
    end
  end
end
