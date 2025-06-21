defmodule Buddy.Month.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Month.Domain, as: Month

  describe "valid?/1" do
    test "returns true for valid month formats" do
      valid_months = [
        "2024-01",
        "2024-12",
        "2025-06"
      ]

      for month <- valid_months do
        assert Month.valid?(month)
      end
    end

    test "returns false for invalid month formats" do
      invalid_months = [
        "2024",
        "2024-1",
        "2024-13",
        "2024-00",
        "invalid",
        nil,
        123
      ]

      for month <- invalid_months do
        refute Month.valid?(month)
      end
    end
  end

  describe "current/0" do
    test "returns current month in YYYY-MM format" do
      current = Month.current()
      assert Month.valid?(current)
    end
  end

  describe "next/1" do
    test "returns next month for middle of year" do
      assert Month.next("2024-06") == "2024-07"
    end

    test "handles year transition" do
      assert Month.next("2024-12") == "2025-01"
    end
  end

  describe "previous/1" do
    test "returns previous month for middle of year" do
      assert Month.previous("2024-06") == "2024-05"
    end

    test "handles year transition" do
      assert Month.previous("2024-01") == "2023-12"
    end
  end

  describe "validate/2" do
    test "adds no error for valid month" do
      changeset =
        fake_schema_with_month()
        |> Ecto.Changeset.cast(%{month: "2024-03"}, [:month])
        |> Month.validate(:month)

      assert changeset.valid?
    end

    test "adds error for invalid month" do
      changeset =
        fake_schema_with_month()
        |> Ecto.Changeset.cast(%{month: "invalid"}, [:month])
        |> Month.validate(:month)

      refute changeset.valid?
      assert "must be in YYYY-MM format" in errors_on(changeset).month
    end
  end

  defp fake_schema_with_month, do: {%{}, %{month: :string}}
end
