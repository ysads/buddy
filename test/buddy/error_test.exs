defmodule Buddy.ErrorTest do
  use ExUnit.Case, async: true

  alias Buddy.Error

  describe "create/2" do
    test "creates an error with only code" do
      assert {:error, error} = Error.create("SOME_ERROR")
      assert error.code == "SOME_ERROR"
      assert error.status == 500
      assert error.details == nil
    end

    test "creates an error with code and status" do
      assert {:error, error} = Error.create("NOT_FOUND", status: 404)
      assert error.code == "NOT_FOUND"
      assert error.status == 404
      assert error.details == nil
    end

    test "creates an error with code and details" do
      assert {:error, error} = Error.create("INVALID_INPUT", details: "Name is required")
      assert error.code == "INVALID_INPUT"
      assert error.status == 500
      assert error.details == "Name is required"
    end

    test "creates an error with all fields" do
      assert {:error, error} =
               Error.create("UNAUTHORIZED", status: 401, details: "Invalid credentials")

      assert error.code == "UNAUTHORIZED"
      assert error.status == 401
      assert error.details == "Invalid credentials"
    end
  end

  describe "struct definition" do
    test "defines a struct with expected fields" do
      error = %Error{code: "TEST", status: 418, details: "I'm a teapot"}
      assert error.code == "TEST"
      assert error.status == 418
      assert error.details == "I'm a teapot"
    end
  end
end
