defmodule Buddy.Account.ServiceTest do
  use Buddy.DataCase, async: true

  alias Buddy.Account.Service
  alias Buddy.Month.Domain, as: Month
  alias Buddy.MonthlySummary.Domain, as: MonthlySummary
  alias Buddy.Repo
  alias Buddy.Transaction.Domain, as: Transaction

  describe "create_with_starting_balance/1" do
    test "creates account with starting balance" do
      attrs = params_for(:account, balance: 10_000)
      assert {:ok, account} = Service.create_with_starting_balance(attrs)

      assert attrs == Map.take(account, [:name, :type, :currency, :balance])
    end

    test "creates an initial income transaction matching balance" do
      attrs = params_for(:account, balance: 10_000)
      assert {:ok, account} = Service.create_with_starting_balance(attrs)

      account = Repo.preload(account, :transactions)
      assert length(account.transactions) == 1

      transaction = hd(account.transactions)
      assert transaction.amount == 10_000
      assert transaction.type == Transaction.types().income
    end

    test "creates a monthly summary for the current month" do
      attrs = params_for(:account, balance: 10_000)
      assert {:ok, _} = Service.create_with_starting_balance(attrs)

      current_month = Month.current()
      current_month_summary = Repo.get_by!(MonthlySummary, month: current_month)

      assert current_month_summary.month == current_month
      assert current_month_summary.income == 10_000
    end
  end

  describe "get_by_id/1" do
    test "returns account if one exists" do
      existing_account = insert(:account)

      assert {:ok, retrieved_account} = Service.get_by_id(existing_account.id)
      assert existing_account.id == retrieved_account.id
    end

    test "returns error if none is found" do
      assert {:error, _} = Service.get_by_id(1)
    end
  end
end
