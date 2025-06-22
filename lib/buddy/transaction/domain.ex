defmodule Buddy.Transaction.Domain do
  @moduledoc """
  A transaction is a record of a financial transaction, with amounts stored in cents.
  It can be associated with another transaction as a transfer pair, to represent a transfer between accounts.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          amount: integer(),
          description: String.t(),
          date: Date.t(),
          account_id: pos_integer(),
          account: Buddy.Account.Domain.t() | nil,
          provision_id: pos_integer(),
          provision: Buddy.Provision.Domain.t() | nil,
          transfer_pair_id: pos_integer() | nil,
          transfer_pair: t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @transaction_types %{
    income: "income",
    expense: "expense"
  }

  schema "transactions" do
    field :amount, :integer
    field :description, :string
    field :date, :date
    field :type, :string

    belongs_to :account, Buddy.Account.Domain, foreign_key: :account_id
    belongs_to :provision, Buddy.Provision.Domain, foreign_key: :provision_id
    belongs_to :transfer_pair, __MODULE__, foreign_key: :transfer_pair_id

    timestamps()
  end

  @required_fields ~w(amount date type account_id provision_id)a
  @optional_fields ~w(description transfer_pair_id)a

  def types, do: @transaction_types

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(transaction \\ %__MODULE__{}, attrs) do
    transaction
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, Map.values(@transaction_types))
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:provision_id)
    |> foreign_key_constraint(:transfer_pair_id)
  end
end
