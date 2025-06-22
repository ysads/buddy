defmodule Buddy.Account.Service do
  @moduledoc """
  Service layer for managing accounts. Contains all business logic for CRUD operations
  that can be shared across different interfaces (CLI, REST, GraphQL, etc).
  """
  import Ecto.Query

  alias Buddy.Account.Domain, as: Account
  alias Buddy.Error
  alias Buddy.Month.Domain, as: Month
  alias Buddy.MonthlySummary.Service, as: MonthlySummaryService
  alias Buddy.Repo
  alias Buddy.Transaction.Domain, as: Transaction
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

  @doc """
  Update the balance of an account.
  """
  @spec update_balance(Account.t(), integer()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def update_balance(account, balance) do
    Account.update_changeset(account, %{balance: balance}) |> Repo.update()
  end

  @spec list_accounts() :: [Account.t()]
  def list_accounts, do: Account |> order_by(asc: :name) |> Repo.all()

  @spec get_by_id(integer()) :: {:ok, Account.t()} | {:error, any()}
  def get_by_id(id) do
    {:ok, Repo.get!(Account, id)}
  rescue
    Ecto.NoResultsError -> Error.create("NOT_FOUND", status: 404, details: "Account not found")
  end

  # Private helpers

  defp initial_transaction(account_id, amount) do
    %{
      account_id: account_id,
      amount: amount,
      reference_at: DateTime.utc_now(),
      type: Transaction.types().income
    }
  end

  defp create_account(params), do: Account.create_changeset(params) |> Repo.insert()
end
