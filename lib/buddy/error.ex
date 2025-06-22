defmodule Buddy.Error do
  @moduledoc """
  Internal error abstraction meant to standardize error responses.

  Instead of handling errors coming from multiple sources and libraries, we can use
  the struct here to create a consistent error response.
  """

  defstruct [:code, :status, :details]

  @type t :: %__MODULE__{
          code: String.t(),
          status: pos_integer(),
          details: String.t() | nil
        }

  @doc """
  Creates an error response using the internal error struct.
  It accepts an optional `status` and `details` keyword arguments.

  ## Examples

  ```elixir
  iex> Buddy.Error.create("NOT_FOUND", status: 404, details: "Account not found")
  {:error, %Buddy.Error{code: "NOT_FOUND", status: 404, details: "Account not found"}}
  ```
  """
  @spec create(String.t(), Keyword.t()) :: {:error, t()}
  def create(code, opts \\ []) do
    {:error,
     %__MODULE__{
       code: code,
       status: Keyword.get(opts, :status, 500),
       details: Keyword.get(opts, :details, nil)
     }}
  end
end
