require "rails_helper"

RSpec.describe CreditEntryItemAllocator do
  def build_item(total:, balance: nil, amount_paid: nil)
    CreditEntryItem.new(
      name: "Item",
      qty: 1,
      unit_price: total,
      total: total,
      balance: balance,
      amount_paid: amount_paid
    )
  end

  describe ".call" do
    it "splits a payment proportionally across two items' balances" do
      items = [build_item(total: 700, balance: 700, amount_paid: 0),
               build_item(total: 300, balance: 300, amount_paid: 0)]

      result = described_class.call(items: items, pay_amount: 500)

      expect(result[0].amount_paid).to eq(350)
      expect(result[0].balance).to eq(350)
      expect(result[1].amount_paid).to eq(150)
      expect(result[1].balance).to eq(150)
      expect(result.sum(&:amount_paid)).to eq(500)
    end

    it "has the last outstanding item absorb the rounding remainder" do
      items = [build_item(total: 100, balance: 33.33, amount_paid: 0),
               build_item(total: 100, balance: 33.33, amount_paid: 0),
               build_item(total: 100, balance: 33.34, amount_paid: 0)]

      result = described_class.call(items: items, pay_amount: 100)

      expect(result.sum(&:amount_paid)).to eq(100)
      expect(result.sum(&:balance)).to eq(0)
    end

    it "skips items that are already fully paid" do
      items = [build_item(total: 100, balance: 0, amount_paid: 100),
               build_item(total: 200, balance: 200, amount_paid: 0),
               build_item(total: 50, balance: 50, amount_paid: 0)]

      result = described_class.call(items: items, pay_amount: 125)

      expect(result[0].amount_paid).to eq(100) # already-paid item must not be touched
      expect(result[1].amount_paid + result[2].amount_paid).to eq(125)
    end

    it "is a no-op when nothing is outstanding" do
      items = [build_item(total: 100, balance: 0, amount_paid: 100)]

      result = described_class.call(items: items, pay_amount: 50)

      expect(result[0].amount_paid).to eq(100)
      expect(result[0].balance).to eq(0)
    end

    it "backfills nil balance/amount_paid from total before allocating" do
      items = [build_item(total: 100, balance: nil, amount_paid: nil)]

      result = described_class.call(items: items, pay_amount: 40)

      expect(result[0].amount_paid).to eq(40)
      expect(result[0].balance).to eq(60)
    end

    it "returns items unchanged for an empty list" do
      expect(described_class.call(items: [], pay_amount: 50)).to eq([])
    end
  end
end