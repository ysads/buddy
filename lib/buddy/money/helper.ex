defmodule Buddy.Money.Helper do
  @moduledoc """
  Helper functions for handling money values. All monetary values are stored
  in cents (integer) internally, but this module helps with formatting and
  parsing decimal values.
  """

  @type amount :: non_neg_integer()
  @type parse_result :: {:ok, amount()} | {:error, String.t()}

  @doc """
  Formats an amount in cents as a decimal string with 2 decimal places.

  ## Examples

      iex> format(1000)
      "10.00"

      iex> format(1550)
      "15.50"

      iex> format(0)
      "0.00"
  """
  @spec format(amount()) :: String.t()
  def format(amount_cents) when is_integer(amount_cents) and amount_cents >= 0 do
    amount = amount_cents / 100
    :io_lib.format("~.2f", [amount]) |> IO.iodata_to_binary()
  end

  @doc """
  Parses a decimal string into cents. Returns {:ok, amount} if successful,
  or {:error, reason} if the string is invalid or negative.

  ## Examples

      iex> parse("10.00")
      {:ok, 1000}

      iex> parse("15.50")
      {:ok, 1550}

      iex> parse("invalid")
      {:error, "invalid money format"}

      iex> parse("-10.00")
      {:error, "amount must be greater than or equal to 0"}
  """
  @spec parse(String.t()) :: parse_result()
  def parse(amount) when is_binary(amount) do
    case Float.parse(amount) do
      {amount, ""} when amount >= 0 -> {:ok, trunc(amount * 100)}
      {_, _} -> {:error, "invalid money format"}
      :error -> {:error, "invalid money format"}
    end
  end

  def parse(_), do: {:error, "invalid money format"}
end
