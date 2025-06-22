defmodule Buddy.Account.Domain do
  @moduledoc """
  A record of a financial account, with amounts stored in cents.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          currency: String.t(),
          balance: non_neg_integer(),
          type: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @account_types %{
    checking: "checking",
    savings: "savings"
  }

  @currencies ~w(USD EUR BRL)

  @required_create_fields [:name, :currency, :balance, :type]
  @optional_update_fields [:name, :balance]

  schema "accounts" do
    field :name, :string
    field :currency, :string
    field :balance, :integer
    field :type, :string

    has_many :transactions, Buddy.Transaction.Domain, foreign_key: :account_id

    timestamps()
  end

  def types, do: @account_types

  def currencies, do: @currencies

  @spec create_changeset(map()) :: Ecto.Changeset.t()
  def create_changeset(account \\ %__MODULE__{}, attrs) do
    account
    |> cast(attrs, @required_create_fields)
    |> validate_required(@required_create_fields)
    |> validate_inclusion(:currency, @currencies)
    |> validate_inclusion(:type, Map.values(@account_types))
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end

  @spec update_changeset(map()) :: Ecto.Changeset.t()
  def update_changeset(account \\ %__MODULE__{}, attrs) do
    account |> cast(attrs, @optional_update_fields)
  end
end
