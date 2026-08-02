class CreditEntry < ApplicationRecord
  belongs_to :shop
  belongs_to :customer
  has_many :credit_entry_items, dependent: :destroy

  VALID_STATUSES = %w[active paid].freeze

  # Ported from utils/creditAgingHelpers.ts on the mobile app. Aged from
  # created_at (when the debt was incurred), not updated_at — standard
  # accounts-receivable-aging convention. A debt with small trickle
  # payments is still "old" if it originated long ago.
  AGING_THRESHOLD_DAYS = 60
  AT_RISK_THRESHOLD_DAYS = 90

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :amount_paid, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: VALID_STATUSES }

  # List-level queries, e.g. "how many at-risk debts does this shop have":
  #   shop.credit_entries.at_risk.count
  scope :current_tier, -> { where("created_at > ?", AGING_THRESHOLD_DAYS.days.ago) }
  scope :aging, -> { where("created_at <= ? AND created_at > ?", AGING_THRESHOLD_DAYS.days.ago, AT_RISK_THRESHOLD_DAYS.days.ago) }
  scope :at_risk, -> { where("created_at <= ?", AT_RISK_THRESHOLD_DAYS.days.ago) }

  # Per-entry equivalents of getEntryAgeDays / getAgingTier, for showing a
  # single entry's age/tier (e.g. an "N days overdue" badge on one entry).
  def age_days
    ((Time.current - created_at) / 1.day).floor.clamp(0..)
  end

  def aging_tier
    return :at_risk if age_days >= AT_RISK_THRESHOLD_DAYS
    return :aging if age_days >= AGING_THRESHOLD_DAYS

    :current
  end
end
