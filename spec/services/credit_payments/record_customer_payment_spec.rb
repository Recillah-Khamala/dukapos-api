require "rails_helper"

RSpec.describe CreditPayments::RecordCustomerPayment do
  let(:shop) { Shop.create!(name: "Kijiji Cereal Store") }
  let(:customer) { Customer.create!(shop: shop, name: "Mama Njeri") }

  def create_entry(customer:, created_at:, total:, items_totals:)
    entry = CreditEntry.create!(
      shop: customer.shop,
      customer: customer,
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

  describe ".call" do
    it "pays the oldest active entry first, in full, before touching a newer one" do
      older = create_entry(customer: customer, created_at: 3.days.ago, total: 100, items_totals: [100])
      newer = create_entry(customer: customer, created_at: 1.day.ago, total: 200, items_totals: [200])

      result = described_class.call(customer: customer, amount: 150)

      expect(older.reload.balance).to eq(0)
      expect(older.status).to eq("paid")
      expect(newer.reload.balance).to eq(150)
      expect(newer.status).to eq("active")
      expect(result.excess).to eq(0)
    end

    it "splits payment proportionally across an entry's items" do
      entry = create_entry(customer: customer, created_at: 1.day.ago, total: 1000, items_totals: [700, 300])

      described_class.call(customer: customer, amount: 500)

      items = entry.credit_entry_items.order(:created_at)
      expect(items[0].reload.amount_paid).to eq(350)
      expect(items[1].reload.amount_paid).to eq(150)
    end

    it "reports excess when payment exceeds all active debt" do
      create_entry(customer: customer, created_at: 1.day.ago, total: 100, items_totals: [100])

      result = described_class.call(customer: customer, amount: 250)

      expect(result.excess).to eq(150)
      expect(result.paid_entries.size).to eq(1)
    end

    it "does not touch entries already marked paid" do
      paid = create_entry(customer: customer, created_at: 2.days.ago, total: 100, items_totals: [100])
      paid.update!(status: "paid", balance: 0, amount_paid: 100)
      active = create_entry(customer: customer, created_at: 1.day.ago, total: 100, items_totals: [100])

      described_class.call(customer: customer, amount: 100)

      expect(paid.reload.amount_paid).to eq(100) # already-paid entry must be left untouched
      expect(active.reload.balance).to eq(0)
    end

    it "raises for a non-positive amount" do
      expect { described_class.call(customer: customer, amount: 0) }.to raise_error(ArgumentError)
      expect { described_class.call(customer: customer, amount: -5) }.to raise_error(ArgumentError)
    end
  end
end