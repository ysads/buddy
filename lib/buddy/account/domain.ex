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
          type: account_type(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @type account_type :: :checking | :savings

  @required_fields ~w(name currency balance type)a

  @permitted_types ~w(checking savings)a
  @permitted_currencies ~w(USD EUR BRL)

  schema "accounts" do
    field :name, :string
    field :currency, :string
    field :balance, :integer
    field :type, Ecto.Enum, values: @permitted_types

    has_many :transactions, Buddy.Transaction.Domain, foreign_key: :account_id

    timestamps()
  end

  @spec account_types :: [account_type()]
  def account_types, do: @permitted_types

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(account \\ %__MODULE__{}, attrs) do
    account
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:currency, @permitted_currencies)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end
end
