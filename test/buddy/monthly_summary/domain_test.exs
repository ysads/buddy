defmodule Buddy.MonthlySummary.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.MonthlySummary.Domain, as: MonthlySummary

  @expected_fields_with_types [
    {:month, :iso_month},
    {:income, :integer},
    {:provisioned, :integer},
    {:spent, :integer},
    {:rollover, :integer},
    {:inserted_at, :datetime},
    {:updated_at, :datetime}
  ]

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      params = valid_params(@expected_fields_with_types)
      changeset = MonthlySummary.changeset(params)

      for {field, _} <- @expected_fields_with_types do
        expected = params[Atom.to_string(field)]
        actual = changeset.changes[Atom.to_string(field)]
        assert expected == actual
      end

      assert changeset.valid?
    end

    test "requires all fields" do
      changeset = MonthlySummary.changeset(%{})

      assert errors_on(changeset) == %{
               month: ["can't be blank"],
               income: ["can't be blank"],
               provisioned: ["can't be blank"],
               spent: ["can't be blank"],
               rollover: ["can't be blank"]
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

    test "validates non-negative amounts" do
      fields = [:income, :provisioned, :spent, :rollover]

      for field <- fields do
        changeset = build_changeset([{field, -1}])

        assert "must be greater than or equal to 0" in errors_on(changeset)[field]
      end
    end

    test "validates uniqueness of month" do
      existing = insert(:monthly_summary)

      changeset = build_changeset(month: existing.month)

      assert {:error, changeset} = Repo.insert(changeset)
      assert "has already been taken" in errors_on(changeset).month
    end
  end

  defp build_changeset(overrides) do
    valid_params(@expected_fields_with_types)
    |> Map.merge(Map.new(overrides))
    |> MonthlySummary.changeset()
  end
end
