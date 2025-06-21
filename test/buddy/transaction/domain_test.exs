defmodule Buddy.Transaction.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Transaction.Domain, as: Transaction

  @expected_fields_with_types [
    {:amount, :integer},
    {:date, :date},
    {:description, :string},
    {:account_id, :integer},
    {:provision_id, :integer},
    {:transfer_pair_id, :integer},
    {:inserted_at, :datetime},
    {:updated_at, :datetime}
  ]

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      params = valid_params(@expected_fields_with_types)
      changeset = Transaction.changeset(params)

      assert changeset.valid?

      for {field, _} <- @expected_fields_with_types do
        expected = params[Atom.to_string(field)]
        actual = changeset.changes[Atom.to_string(field)]
        assert expected == actual
      end
    end

    test "requires mandatory fields" do
      changeset = Transaction.changeset(%{})

      assert errors_on(changeset) == %{
               amount: ["can't be blank"],
               date: ["can't be blank"],
               account_id: ["can't be blank"],
               provision_id: ["can't be blank"]
             }
    end

    test "description is optional" do
      changeset = build_changeset(description: nil)

      assert changeset.valid?
    end

    test "transfer_pair_id is optional" do
      changeset = build_changeset(transfer_pair_id: nil)

      assert changeset.valid?
    end
  end

  defp build_changeset(overrides) do
    valid_params(@expected_fields_with_types)
    |> Map.merge(Map.new(overrides))
    |> Transaction.changeset()
  end
end
