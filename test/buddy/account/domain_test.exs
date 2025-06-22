defmodule Buddy.Account.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Account.Domain, as: Account

  @expected_fields_with_types [
    name: :string,
    currency: :string,
    balance: :integer,
    type: :string
  ]

  describe "create_changeset/2" do
    test "valid attributes create a valid changeset" do
      attrs = create_attrs()

      changeset = Account.create_changeset(attrs)
      assert changeset.valid?

      for {field, _} <- @expected_fields_with_types do
        expected = attrs[field]
        actual = changeset.changes[field]

        assert expected == actual
      end
    end

    test "validates account type" do
      changeset = create_attrs(%{type: "invalid"}) |> Account.create_changeset()

      assert "is invalid" in errors_on(changeset).type
    end

    test "validates currency" do
      changeset = create_attrs(%{currency: "INV"}) |> Account.create_changeset()

      assert "is invalid" in errors_on(changeset).currency
    end

    test "validates non-negative balance" do
      changeset = create_attrs(%{balance: -1}) |> Account.create_changeset()

      assert "must be greater than or equal to 0" in errors_on(changeset).balance
    end

    test "requires all fields" do
      changeset = Account.create_changeset(%{})

      assert errors_on(changeset) == %{
               name: ["can't be blank"],
               currency: ["can't be blank"],
               balance: ["can't be blank"],
               type: ["can't be blank"]
             }
    end
  end

  describe "update_changeset/2" do
    test "valid attributes create a valid changeset" do
      account = build(:account, name: "Test")
      attrs = %{name: "New Name"}

      changeset = Account.update_changeset(account, attrs)

      assert changeset.valid?
      assert changeset.changes.name == "New Name"
    end

    test "non permitted attributes are ignored" do
      account = build(:account, type: Account.types().checking, currency: "USD", balance: 100)
      attrs = %{type: Account.types().savings, currency: "EUR", balance: 200}

      changeset = Account.update_changeset(account, attrs)
      assert changeset.valid?

      for {field, _} <- changeset.changes do
        assert changeset.changes[field] == nil
      end
    end
  end

  test "types/0" do
    assert Account.types() == %{checking: "checking", savings: "savings"}
  end

  test "currencies/0" do
    assert Account.currencies() == ["USD", "EUR", "BRL"]
  end

  defp create_attrs(overrides \\ %{}) do
    valid_params(@expected_fields_with_types)
    |> Map.put(:type, Account.types().checking)
    |> Map.put(:currency, "USD")
    |> Map.merge(overrides)
  end
end
