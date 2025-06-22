defmodule Buddy.MonthlySummary.ServiceTest do
  use Buddy.DataCase, async: true

  alias Buddy.MonthlySummary.Service
  alias Buddy.Transaction.Domain, as: Transaction

  describe "find_or_create_summary/1" do
    test "returns existing summary for given month if it exists" do
      iso_month = "2025-01"
      existing_summary = insert(:monthly_summary, month: iso_month)

      assert {:ok, summary} = Service.find_or_create_summary(iso_month)
      assert summary.id == existing_summary.id
    end

    test "creates a new summary with defaults for given month if it doesn't exist" do
      iso_month = "2025-01"

      assert {:ok, summary} = Service.find_or_create_summary(iso_month)
      assert summary.month == iso_month
      assert summary.income == 0
      assert summary.provisioned == 0
      assert summary.spent == 0
      assert summary.rollover == 0
    end

    test "creates a new summary with totals if any are given" do
      iso_month = "2025-01"
      attrs = %{income: 100, provisioned: 200}

      assert {:ok, summary} = Service.find_or_create_summary(iso_month, attrs)
      assert summary.month == iso_month
      assert summary.income == 100
      assert summary.provisioned == 200
      assert summary.spent == 0
      assert summary.rollover == 0
    end

    test "returns error if given something other than an iso_month" do
      assert {:error, _} = Service.find_or_create_summary("2025-01-01")
      assert {:error, _} = Service.find_or_create_summary(DateTime.utc_now())
      assert {:error, _} = Service.find_or_create_summary(123)
    end
  end

  describe "update_from_transaction/2" do
    test "updates income if transaction is income" do
      summary = insert(:monthly_summary, income: 0, spent: 0)
      transaction = insert(:transaction, amount: 100, type: Transaction.types().income)

      assert {:ok, _} = Service.update_from_transaction(summary, transaction)

      summary = Repo.reload!(summary)
      assert summary.income == 100
    end

    test "updates spent if transaction is expense" do
      summary = insert(:monthly_summary, income: 0, spent: 0)
      transaction = insert(:transaction, amount: 100, type: Transaction.types().expense)

      assert {:ok, _} = Service.update_from_transaction(summary, transaction)

      summary = Repo.reload!(summary)
      assert summary.spent == 100
    end
  end
end
