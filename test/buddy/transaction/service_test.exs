defmodule Buddy.Transaction.ServiceTest do
  use Buddy.DataCase, async: true

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
end
