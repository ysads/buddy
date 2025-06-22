defmodule Buddy.Transaction.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Transaction.Domain, as: Transaction

  @expected_fields_with_types [
    {:amount, :integer},
    {:date, :date},
    {:description, :string},
    {:type, :string},
    {:account_id, :integer},
    {:provision_id, :integer},
    {:transfer_pair_id, :integer},
    {:inserted_at, :datetime},
    {:updated_at, :datetime}
  ]

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      attrs = create_attrs()

      changeset = Transaction.changeset(attrs)

      assert changeset.valid?

      for {field, _} <- @expected_fields_with_types do
        expected = attrs[Atom.to_string(field)]
        actual = changeset.changes[Atom.to_string(field)]
        assert expected == actual
      end
    end

    test "requires mandatory fields" do
      changeset = Transaction.changeset(%{})

      assert errors_on(changeset) == %{
               amount: ["can't be blank"],
               date: ["can't be blank"],
               type: ["can't be blank"],
               account_id: ["can't be blank"],
               provision_id: ["can't be blank"]
             }
    end

    test "validates type" do
      changeset = create_attrs(%{type: "invalid"}) |> Transaction.changeset()

      assert errors_on(changeset) == %{type: ["is invalid"]}
    end

    test "description is optional" do
      changeset = create_attrs(%{description: nil}) |> Transaction.changeset()

      assert changeset.valid?
    end

    test "transfer_pair_id is optional" do
      changeset = create_attrs(%{transfer_pair_id: nil}) |> Transaction.changeset()

      assert changeset.valid?
    end
  end

  describe "types/0" do
    test "returns the transaction types" do
      assert Transaction.types() == %{income: "income", expense: "expense"}
    end
  end

  defp create_attrs(overrides \\ %{}) do
    valid_params(@expected_fields_with_types)
    |> Map.put(:type, Transaction.types().expense)
    |> Map.merge(overrides)
  end
end
