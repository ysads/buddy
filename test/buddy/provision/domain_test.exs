defmodule Buddy.Provision.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Provision.Domain, as: Provision

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      changeset = build(:provision) |> Map.from_struct() |> Provision.changeset()

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
        changeset =
          build(:provision, month: invalid_month) |> Map.from_struct() |> Provision.changeset()

        assert "must be in YYYY-MM format" in errors_on(changeset).month
      end
    end

    test "validates non-negative amount" do
      changeset = build(:provision, amount: -1) |> Map.from_struct() |> Provision.changeset()

      assert "must be greater than or equal to 0" in errors_on(changeset).amount
    end
  end
end
