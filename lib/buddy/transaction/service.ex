defmodule Buddy.Transaction.Service do
  @moduledoc """
  Service for managing transactions.
  """

  alias Buddy.Account.Service, as: AccountService
  alias Buddy.Month.Domain, as: Month
  alias Buddy.MonthlySummary.Service, as: MonthlySummaryService
  alias Buddy.Repo
  alias Buddy.Transaction.Domain, as: Transaction

  @doc """
  Add a transaction to an account, updating the account balance and adjusting the monthly summary.
  """
  @spec register_transaction(map()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def register_transaction(%{account_id: account_id} = params) when is_integer(account_id) do
    balance_delta =
      cond do
        params.type == Transaction.types().income -> params.amount
        params.type == Transaction.types().expense -> -params.amount
      end

    with {:ok, account} <- AccountService.get_by_id(account_id),
         {:ok, _} <- AccountService.update_balance(account, account.balance + balance_delta),
         {:ok, transaction} <- create_transaction(params),
         transaction_month <- Month.of(transaction.reference_at),
         {:ok, summary} <- MonthlySummaryService.find_or_create_summary(transaction_month),
         {:ok, _} <- MonthlySummaryService.update_from_transaction(summary, transaction) do
      {:ok, transaction}
    end
  end

  def register_transaction(_), do: {:error, "Account ID is required"}

  def create_transaction(attrs) do
    Transaction.changeset(%Transaction{}, attrs) |> Repo.insert()
  end
end
