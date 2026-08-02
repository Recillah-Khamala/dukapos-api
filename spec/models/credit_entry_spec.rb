require "rails_helper"

RSpec.describe CreditEntry do
  let(:shop) { Shop.create!(name: "Kijiji Cereal Store") }
  let(:customer) { Customer.create!(shop: shop, name: "Mama Njeri") }

  def create_entry(days_old:, status: "active")
    CreditEntry.create!(
      shop: shop,
      customer: customer,
      total_amount: 100,
      amount_paid: 0,
      balance: 100,
      status: status,
      created_at: days_old.days.ago
    )
  end

  describe "#age_days" do
    it "returns the number of whole days since created_at" do
      entry = create_entry(days_old: 45)
      expect(entry.age_days).to eq(45)
    end

    it "never returns a negative value" do
      entry = create_entry(days_old: 0)
      expect(entry.age_days).to be >= 0
    end
  end

  describe "#aging_tier" do
    it "is :current under 60 days old" do
      expect(create_entry(days_old: 59).aging_tier).to eq(:current)
    end

    it "is :aging at exactly 60 days old" do
      expect(create_entry(days_old: 60).aging_tier).to eq(:aging)
    end

    it "is :aging at 89 days old" do
      expect(create_entry(days_old: 89).aging_tier).to eq(:aging)
    end

    it "is :at_risk at exactly 90 days old" do
      expect(create_entry(days_old: 90).aging_tier).to eq(:at_risk)
    end

    it "is :at_risk well past 90 days old" do
      expect(create_entry(days_old: 200).aging_tier).to eq(:at_risk)
    end
  end

  describe "scopes" do
    it "current_tier only includes entries under 60 days old" do
      young = create_entry(days_old: 10)
      create_entry(days_old: 60)
      create_entry(days_old: 120)

      expect(CreditEntry.current_tier).to contain_exactly(young)
    end

    it "aging only includes entries between 60 and 89 days old" do
      create_entry(days_old: 10)
      aging_entry = create_entry(days_old: 75)
      create_entry(days_old: 90)

      expect(CreditEntry.aging).to contain_exactly(aging_entry)
    end

    it "at_risk only includes entries 90 days or older" do
      create_entry(days_old: 10)
      create_entry(days_old: 89)
      at_risk_entry = create_entry(days_old: 90)
      very_old_entry = create_entry(days_old: 400)

      expect(CreditEntry.at_risk).to contain_exactly(at_risk_entry, very_old_entry)
    end

    it "partitions every entry into exactly one tier, with no gaps or overlap" do
      entries = [ 0, 30, 59, 60, 61, 89, 90, 91, 365 ].map { |d| create_entry(days_old: d) }

      tiered = CreditEntry.current_tier.to_a + CreditEntry.aging.to_a + CreditEntry.at_risk.to_a
      expect(tiered.map(&:id).sort).to eq(entries.map(&:id).sort)
    end
  end
end
