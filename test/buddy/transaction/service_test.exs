defmodule Buddy.Transaction.ServiceTest do
  use Buddy.DataCase, async: true

  alias Buddy.Month.Domain, as: Month
  alias Buddy.MonthlySummary.Domain, as: MonthlySummary
  alias Buddy.Transaction.Domain, as: Transaction
  alias Buddy.Transaction.Service, as: TransactionService

  describe "create_transaction/1" do
    test "persists a new transaction" do
      attrs = params_with_assocs(:transaction)
      assert {:ok, transaction} = TransactionService.create_transaction(attrs)
      assert transaction.id
    end

    test "returns an error if the transaction is invalid" do
      attrs = params_with_assocs(:transaction, amount: nil)
      assert {:error, changeset} = TransactionService.create_transaction(attrs)
      assert errors_on(changeset).amount == ["can't be blank"]
    end
  end

  describe "register_transaction/1" do
    test "persists a new transaction" do
      attrs = params_with_assocs(:transaction)
      assert {:ok, transaction} = TransactionService.register_transaction(attrs)
      assert attrs = Map.from_struct(transaction)
    end

    test "increases account balance if transaction is income" do
      account = insert(:account, balance: 100)

      attrs =
        params_with_assocs(:transaction,
          account: account,
          amount: 100,
          type: Transaction.types().income
        )

      assert {:ok, transaction} = TransactionService.register_transaction(attrs)

      account = Repo.reload!(account)
      assert account.balance == 200
    end

    test "decreases account balance if transaction is expense" do
      account = insert(:account, balance: 300)

      attrs =
        params_with_assocs(:transaction,
          account: account,
          amount: 100,
          type: Transaction.types().expense
        )

      assert {:ok, transaction} = TransactionService.register_transaction(attrs)

      account = Repo.reload!(account)
      assert account.balance == 200
    end

    test "updates monthly summary income if transaction is income" do
      attrs = params_with_assocs(:transaction, amount: 100, type: Transaction.types().income)

      assert {:ok, transaction} = TransactionService.register_transaction(attrs)

      summary = Repo.get_by(MonthlySummary, month: Month.of(transaction.reference_at))
      assert summary.income == 100
    end

    test "updates monthly summary spent if transaction is expense" do
      attrs = params_with_assocs(:transaction, amount: 100, type: Transaction.types().expense)

      assert {:ok, transaction} = TransactionService.register_transaction(attrs)

      summary = Repo.get_by(MonthlySummary, month: Month.of(transaction.reference_at))
      assert summary.spent == 100
    end
  end
end
