defmodule Buddy.Category.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "categories" do
    field :name, :string

    has_many :provisions, Buddy.Provision.Domain, foreign_key: :category_id

    timestamps()
  end

  @required_fields ~w(name)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(category \\ %__MODULE__{}, attrs) do
    category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
