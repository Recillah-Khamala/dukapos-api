class SetCreditEntryItemsBalanceDefault < ActiveRecord::Migration[8.0]
  def change
    # amount_paid already defaults to 0.0 (see CreateCreditEntryItems). balance
    # was left without a default, relying on callers to always set it. This
    # backend has no legacy AsyncStorage-era rows to backfill (unlike the old
    # mobile-app normalizeEntry helper, which patched null balances from before
    # partial-payment support existed) — a DB default is a safety net for any
    # future insert path that forgets to set it explicitly, not a data fix.
    change_column_default :credit_entry_items, :balance, from: nil, to: 0
  end
end