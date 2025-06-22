defmodule Buddy.Account.Service do
  @moduledoc """
  Service layer for managing accounts. Contains all business logic for CRUD operations
  that can be shared across different interfaces (CLI, REST, GraphQL, etc).
  """

  alias Buddy.Account.Domain, as: Account
  alias Buddy.Month.Domain, as: Month
  alias Buddy.MonthlySummary.Service, as: MonthlySummaryService
  alias Buddy.Repo
  alias Buddy.Transaction
  alias Buddy.Transaction.Service, as: TransactionService

  @type create_params :: %{
          name: String.t(),
          type: String.t(),
          currency: String.t(),
          balance: non_neg_integer()
        }

  @doc """
  Setup a new account with a balance. This creates an initial transaction with the passed balance and adds it
  to the current month's income.
  """
  @spec create_with_starting_balance(create_params()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def create_with_starting_balance(params) do
    with {:ok, account} <- create_account(params),
         {:ok, _} <-
           TransactionService.create_transaction(initial_transaction(account.id, params.balance)),
         {:ok, _} <-
           MonthlySummaryService.find_or_create_summary(Month.current(), %{income: params.balance}) do
      {:ok, account}
    end
  end

  # Private helpers

  defp initial_transaction(account_id, amount) do
    %{
      account_id: account_id,
      amount: amount,
      reference_at: DateTime.utc_now(),
      type: Transaction.Domain.types().income
    }
  end

  defp create_account(params), do: Account.create_changeset(params) |> Repo.insert()
end
