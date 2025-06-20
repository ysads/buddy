defmodule Buddy.Account.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Account.Domain, as: Account

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      changeset = build(:account) |> Map.from_struct() |> Account.changeset()
      assert changeset.valid?
    end

    test "validates account type" do
      changeset = Account.changeset(invalid_account(type: "invalid"))

      assert "is invalid" in errors_on(changeset).type
    end

    test "validates currency" do
      changeset = Account.changeset(invalid_account(currency: "INVALID"))

      assert "is invalid" in errors_on(changeset).currency
    end

    test "validates non-negative balance" do
      changeset = Account.changeset(invalid_account(balance: -1))

      assert "must be greater than or equal to 0" in errors_on(changeset).balance
    end

    test "requires all fields" do
      changeset = Account.changeset(%{})

      assert errors_on(changeset) == %{
               name: ["can't be blank"],
               currency: ["can't be blank"],
               balance: ["can't be blank"],
               type: ["can't be blank"]
             }
    end
  end

  defp invalid_account(overrides), do: build(:account, overrides) |> Map.from_struct()
end
