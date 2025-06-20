defmodule Buddy.Transaction.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Transaction.Domain, as: Transaction

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      changeset = build(:transaction) |> Map.from_struct() |> Transaction.changeset()

      assert changeset.valid?
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
      changeset =
        build(:transaction, description: nil) |> Map.from_struct() |> Transaction.changeset()

      assert changeset.valid?
    end

    test "transfer_pair_id is optional" do
      changeset =
        build(:transaction, transfer_pair_id: nil) |> Map.from_struct() |> Transaction.changeset()

      assert changeset.valid?
    end
  end
end
