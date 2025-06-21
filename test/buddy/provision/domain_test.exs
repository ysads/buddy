defmodule Buddy.Provision.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Provision.Domain, as: Provision

  @expected_fields_with_types [
    {:month, :iso_month},
    {:amount, :integer},
    {:category_id, :integer},
    {:inserted_at, :datetime},
    {:updated_at, :datetime}
  ]

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      params = valid_params(@expected_fields_with_types)
      changeset = Provision.changeset(params)

      for {field, _} <- @expected_fields_with_types do
        expected = params[Atom.to_string(field)]
        actual = changeset.changes[Atom.to_string(field)]
        assert expected == actual
      end

      assert changeset.valid?
    end

    test "requires all fields" do
      changeset = Provision.changeset(%{})

      assert errors_on(changeset) == %{
               month: ["can't be blank"],
               amount: ["can't be blank"],
               category_id: ["can't be blank"]
             }
    end

    test "validates month format" do
      invalid_formats = [
        "2024",
        "2024-1",
        "2024-13",
        "2024-00",
        "invalid"
      ]

      for invalid_month <- invalid_formats do
        changeset = build_changeset(month: invalid_month)

        assert "must be in YYYY-MM format" in errors_on(changeset).month
      end
    end

    test "validates non-negative amount" do
      changeset = build_changeset(amount: -1)

      assert "must be greater than or equal to 0" in errors_on(changeset).amount
    end

    test "validates uniqueness of category per month" do
      existing = insert(:provision)

      changeset =
        build_changeset(month: existing.month, category_id: existing.category_id)

      assert {:error, changeset} = Repo.insert(changeset)
      assert "has already been taken" in errors_on(changeset).category_id
    end
  end

  defp build_changeset(overrides) do
    valid_params(@expected_fields_with_types)
    |> Map.merge(Map.new(overrides))
    |> Provision.changeset()
  end
end
