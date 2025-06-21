defmodule Buddy.Provision.Domain do
  @moduledoc """
  A provision is a record of monthly allocation of money for a category, with amounts stored in cents.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Buddy.Month.Domain, as: Month

  @type t :: %__MODULE__{
          month: Month.t(),
          amount: non_neg_integer(),
          category_id: pos_integer(),
          category: Buddy.Category.Domain.t() | nil,
          transactions: [Buddy.Transaction.Domain.t()],
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "provisions" do
    field :month, :string
    field :amount, :integer

    belongs_to :category, Buddy.Category.Domain, foreign_key: :category_id, references: :id
    has_many :transactions, Buddy.Transaction.Domain, foreign_key: :provision_id, references: :id

    timestamps()
  end

  @required_fields ~w(month amount category_id)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(provision \\ %__MODULE__{}, attrs) do
    provision
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> Month.validate(:month)
    |> foreign_key_constraint(:category_id)
    |> unique_constraint([:category_id, :month])
  end
end
