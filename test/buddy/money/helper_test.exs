defmodule Buddy.Money.HelperTest do
  use ExUnit.Case, async: true

  alias Buddy.Money.Helper

  describe "format/1" do
    test "formats zero" do
      assert Helper.format(0) == "0.00"
    end

    test "formats whole numbers" do
      assert Helper.format(1000) == "10.00"
      assert Helper.format(50000) == "500.00"
    end

    test "formats decimal numbers" do
      assert Helper.format(1550) == "15.50"
      assert Helper.format(1505) == "15.05"
      assert Helper.format(1501) == "15.01"
    end
  end

  describe "parse/1" do
    test "parses whole numbers" do
      assert Helper.parse("10.00") == {:ok, 1000}
      assert Helper.parse("500.00") == {:ok, 50000}
    end

    test "parses decimal numbers" do
      assert Helper.parse("15.50") == {:ok, 1550}
      assert Helper.parse("15.05") == {:ok, 1505}
      assert Helper.parse("15.01") == {:ok, 1501}
    end

    test "parses numbers without decimals" do
      assert Helper.parse("10") == {:ok, 1000}
      assert Helper.parse("500") == {:ok, 50000}
    end

    test "returns error for invalid format" do
      assert Helper.parse("invalid") == {:error, "invalid money format"}
      assert Helper.parse("10.") == {:error, "invalid money format"}
      assert Helper.parse(".10") == {:error, "invalid money format"}
    end

    test "returns error for negative numbers" do
      assert Helper.parse("-10.00") == {:error, "invalid money format"}
      assert Helper.parse("-500") == {:error, "invalid money format"}
    end

    test "returns error for non-string input" do
      assert Helper.parse(nil) == {:error, "invalid money format"}
      assert Helper.parse(123) == {:error, "invalid money format"}
      assert Helper.parse(%{}) == {:error, "invalid money format"}
    end
  end
end
