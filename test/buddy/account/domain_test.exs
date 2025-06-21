defmodule Buddy.Account.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Account.Domain, as: Account

  @expected_fields_with_types [
    name: :string,
    currency: :string,
    balance: :integer,
    type: :string
  ]

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      params = valid_account()
      changeset = Account.changeset(params)

      assert changeset.valid?

      for {field, _} <- @expected_fields_with_types do
        expected = params[field]
        actual = changeset.changes[field]

        assert expected == actual
      end
    end

    test "validates account type" do
      changeset = build_changeset(type: "invalid")

      assert "is invalid" in errors_on(changeset).type
    end

    test "validates currency" do
      changeset = build_changeset(currency: "INVALID")

      assert "is invalid" in errors_on(changeset).currency
    end

    test "validates non-negative balance" do
      changeset = build_changeset(balance: -1)

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

  defp valid_account do
    valid_params(@expected_fields_with_types)
    |> Map.put(:type, :checking)
    |> Map.put(:currency, "USD")
  end

  defp build_changeset(overrides) do
    valid_account()
    |> Map.merge(Map.new(overrides))
    |> Account.changeset()
  end
end
