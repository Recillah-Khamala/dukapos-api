require "test_helper"

class CreditEntryItemAllocatorTest < ActiveSupport::TestCase
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

  test "splits a payment proportionally across two items' balances" do
    items = [build_item(total: 700, balance: 700, amount_paid: 0),
             build_item(total: 300, balance: 300, amount_paid: 0)]

    result = CreditEntryItemAllocator.call(items: items, pay_amount: 500)

    assert_equal 350, result[0].amount_paid
    assert_equal 350, result[0].balance
    assert_equal 150, result[1].amount_paid
    assert_equal 150, result[1].balance
    assert_equal 500, result.sum(&:amount_paid)
  end

  test "last outstanding item absorbs the rounding remainder" do
    items = [build_item(total: 100, balance: 33.33, amount_paid: 0),
             build_item(total: 100, balance: 33.33, amount_paid: 0),
             build_item(total: 100, balance: 33.34, amount_paid: 0)]

    result = CreditEntryItemAllocator.call(items: items, pay_amount: 100)

    assert_equal 100, result.sum(&:amount_paid)
    assert_equal 0, result.sum(&:balance)
  end

  test "skips items that are already fully paid" do
    items = [build_item(total: 100, balance: 0, amount_paid: 100),
             build_item(total: 200, balance: 200, amount_paid: 0),
             build_item(total: 50, balance: 50, amount_paid: 0)]

    result = CreditEntryItemAllocator.call(items: items, pay_amount: 125)

    assert_equal 100, result[0].amount_paid, "already-paid item must not be touched"
    assert_equal 125, result[1].amount_paid + result[2].amount_paid
  end

  test "is a no-op when nothing is outstanding" do
    items = [build_item(total: 100, balance: 0, amount_paid: 100)]

    result = CreditEntryItemAllocator.call(items: items, pay_amount: 50)

    assert_equal 100, result[0].amount_paid
    assert_equal 0, result[0].balance
  end

  test "backfills nil balance/amount_paid from total before allocating" do
    items = [build_item(total: 100, balance: nil, amount_paid: nil)]

    result = CreditEntryItemAllocator.call(items: items, pay_amount: 40)

    assert_equal 40, result[0].amount_paid
    assert_equal 60, result[0].balance
  end

  test "returns items unchanged for an empty list" do
    assert_equal [], CreditEntryItemAllocator.call(items: [], pay_amount: 50)
  end
end
