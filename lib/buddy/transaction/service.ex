defmodule Buddy.Transaction.Service do
  @moduledoc """
  Service for managing transactions.
  """

  alias Buddy.Repo
  alias Buddy.Transaction.Domain, as: Transaction

  def create_transaction(attrs) do
    Transaction.changeset(attrs)
    |> Repo.insert()
  end
end
