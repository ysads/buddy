defmodule Buddy.MonthlySummary.Service do
  @moduledoc """
  Service for managing monthly summaries.
  """

  alias Buddy.Month.Domain, as: Month
  alias Buddy.MonthlySummary.Domain, as: MonthlySummary
  alias Buddy.Repo

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

  defp create_summary(month, attrs) do
    %{month: month, income: 0, provisioned: 0, spent: 0, rollover: 0}
    |> Map.merge(attrs)
    |> MonthlySummary.changeset()
    |> Repo.insert()
  end
end
