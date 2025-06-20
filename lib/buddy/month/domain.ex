defmodule Buddy.Month.Domain do
  @moduledoc """
  Domain module for handling month format (YYYY-MM) across the application.
  """

  @type t :: String.t()

  @month_regex ~r/^\d{4}-(?:0[1-9]|1[0-2])$/

  @doc """
  Validates that a month string follows the YYYY-MM format.
  Returns a changeset with error if validation fails.
  """
  @spec validate(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def validate(changeset, field) do
    Ecto.Changeset.validate_format(changeset, field, @month_regex,
      message: "must be in YYYY-MM format"
    )
  end

  @doc """
  Returns true if the given string is a valid month in YYYY-MM format.
  """
  @spec valid?(String.t()) :: boolean()
  def valid?(month) when is_binary(month), do: Regex.match?(@month_regex, month)
  def valid?(_), do: false

  @doc """
  Returns the current month in YYYY-MM format.
  """
  @spec current() :: t()
  def current do
    DateTime.utc_now()
    |> Calendar.strftime("%Y-%m")
  end

  @doc """
  Returns the next month in YYYY-MM format.
  """
  @spec next(t()) :: t()
  def next(month) do
    with [year, month] <- String.split(month, "-"),
         {year, ""} <- Integer.parse(year),
         {month, ""} <- Integer.parse(month) do
      case month do
        12 -> "#{year + 1}-01"
        m -> "#{year}-#{String.pad_leading("#{m + 1}", 2, "0")}"
      end
    end
  end

  @doc """
  Returns the previous month in YYYY-MM format.
  """
  @spec previous(t()) :: t()
  def previous(month) do
    with [year, month] <- String.split(month, "-"),
         {year, ""} <- Integer.parse(year),
         {month, ""} <- Integer.parse(month) do
      case month do
        1 -> "#{year - 1}-12"
        m -> "#{year}-#{String.pad_leading("#{m - 1}", 2, "0")}"
      end
    end
  end
end
