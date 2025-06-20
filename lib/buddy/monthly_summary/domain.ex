defmodule Buddy.MonthlySummary.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  alias Buddy.Month.Domain, as: Month

  @type t :: %__MODULE__{
          month: Month.t(),
          income: non_neg_integer(),
          provisioned: non_neg_integer(),
          spent: non_neg_integer(),
          rollover: non_neg_integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "monthly_summaries" do
    field :month, :string
    field :income, :integer
    field :provisioned, :integer
    field :spent, :integer
    field :rollover, :integer

    timestamps()
  end

  @fields ~w(month income provisioned spent rollover)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(summary \\ %__MODULE__{}, attrs) do
    summary
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> Month.validate(:month)
    |> validate_number(:income, greater_than_or_equal_to: 0)
    |> validate_number(:provisioned, greater_than_or_equal_to: 0)
    |> validate_number(:spent, greater_than_or_equal_to: 0)
    |> validate_number(:rollover, greater_than_or_equal_to: 0)
    |> unique_constraint(:month)
  end
end
