defmodule Buddy.MonthlySummary.Service do
  @moduledoc """
  Service for managing monthly summaries.
  """

  import Buddy.Transaction.Domain, only: [is_income: 1, is_expense: 1]

  alias Buddy.Month.Domain, as: Month
  alias Buddy.MonthlySummary.Domain, as: MonthlySummary
  alias Buddy.Repo
  alias Buddy.Transaction.Domain, as: Transaction

  @doc """
  Finds or creates a monthly summary for the given ISO month.
  """
  @spec find_or_create_summary(Month.t()) ::
          {:ok, MonthlySummary.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create_summary(month, attrs \\ %{}) do
    if Month.valid?(month) do
      case Repo.get_by(MonthlySummary, month: month) do
        nil -> create_summary(month, attrs)
        summary -> {:ok, summary}
      end
    else
      {:error, "Invalid month format"}
    end
  end

  @doc """
  Incorporates a transaction into the monthly summary totals.
  """
  @spec update_from_transaction(MonthlySummary.t(), Transaction.t()) ::
          {:ok, MonthlySummary.t()} | {:error, Ecto.Changeset.t()}
  def update_from_transaction(monthly_summary, %{type: type} = transaction)
      when is_income(type),
      do: update_totals(monthly_summary, :income, transaction.amount)

  def update_from_transaction(monthly_summary, %{type: type} = transaction)
      when is_expense(type),
      do: update_totals(monthly_summary, :spent, transaction.amount)

  # Private helpers

  defp update_totals(monthly_summary, column, amount) do
    new_total = Map.get(monthly_summary, column) + amount

    MonthlySummary.changeset(monthly_summary, Map.new([{column, new_total}])) |> Repo.update()
  end

  defp create_summary(month, attrs) do
    %{month: month, income: 0, provisioned: 0, spent: 0, rollover: 0}
    |> Map.merge(attrs)
    |> MonthlySummary.changeset()
    |> Repo.insert()
  end
end
