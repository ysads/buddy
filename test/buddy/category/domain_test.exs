defmodule Buddy.Category.DomainTest do
  use Buddy.DataCase, async: true

  alias Buddy.Category.Domain, as: Category

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      changeset = Category.changeset(%{name: "Groceries"})
      assert changeset.valid?
    end

    test "requires name" do
      changeset = Category.changeset(%{})
      assert "can't be blank" in errors_on(changeset).name
    end
  end
end
