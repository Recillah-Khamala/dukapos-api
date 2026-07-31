require "test_helper"

module CreditPayments
  class RecordCustomerPaymentTest < ActiveSupport::TestCase
    setup do
      @shop = Shop.create!(name: "Kijiji Cereal Store")
      @customer = Customer.create!(shop: @shop, name: "Mama Njeri")
    end

    def create_entry(created_at:, total:, items_totals:)
      entry = CreditEntry.create!(
        shop: @shop,
        customer: @customer,
        total_amount: total,
        amount_paid: 0,
        balance: total,
        status: "active",
        created_at: created_at
      )
      items_totals.each do |item_total|
        entry.credit_entry_items.create!(
          name: "Item", qty: 1, unit_price: item_total, total: item_total,
          amount_paid: 0, balance: item_total
        )
      end
      entry
    end

    test "pays the oldest active entry first, in full, before touching a newer one" do
      older = create_entry(created_at: 3.days.ago, total: 100, items_totals: [100])
      newer = create_entry(created_at: 1.day.ago, total: 200, items_totals: [200])

      result = RecordCustomerPayment.call(customer: @customer, amount: 150)

      assert_equal 0, older.reload.balance
      assert_equal "paid", older.status
      assert_equal 50, newer.reload.balance
      assert_equal "active", newer.status
      assert_equal 0, result.excess
    end

    test "splits payment proportionally across an entry's items" do
      entry = create_entry(created_at: 1.day.ago, total: 1000, items_totals: [700, 300])

      RecordCustomerPayment.call(customer: @customer, amount: 500)

      items = entry.credit_entry_items.order(:created_at)
      assert_equal 350, items[0].reload.amount_paid
      assert_equal 150, items[1].reload.amount_paid
    end

    test "reports excess when payment exceeds all active debt" do
      create_entry(created_at: 1.day.ago, total: 100, items_totals: [100])

      result = RecordCustomerPayment.call(customer: @customer, amount: 250)

      assert_equal 150, result.excess
      assert_equal 1, result.paid_entries.size
    end

    test "does not touch entries already marked paid" do
      paid = create_entry(created_at: 2.days.ago, total: 100, items_totals: [100])
      paid.update!(status: "paid", balance: 0, amount_paid: 100)
      active = create_entry(created_at: 1.day.ago, total: 100, items_totals: [100])

      RecordCustomerPayment.call(customer: @customer, amount: 100)

      assert_equal 100, paid.reload.amount_paid, "already-paid entry must be left untouched"
      assert_equal 0, active.reload.balance
    end

    test "raises for a non-positive amount" do
      assert_raises(ArgumentError) { RecordCustomerPayment.call(customer: @customer, amount: 0) }
      assert_raises(ArgumentError) { RecordCustomerPayment.call(customer: @customer, amount: -5) }
    end
  end
end
