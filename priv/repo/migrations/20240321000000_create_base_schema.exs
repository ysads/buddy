defmodule Buddy.Repo.Migrations.CreateBaseSchema do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :currency, :string, null: false
      add :balance, :bigint, null: false, default: 0
      add :type, :string, null: false

      timestamps()
    end

    create table(:categories) do
      add :name, :string, null: false

      timestamps()
    end

    create table(:provisions) do
      add :month, :string, null: false
      add :amount, :bigint, null: false
      add :category_id, references(:categories, on_delete: :restrict), null: false

      timestamps()
    end

    # Ensure we can't have duplicate provisions for the same category in a month
    create unique_index(:provisions, [:category_id, :month])

    create table(:transactions) do
      add :amount, :bigint, null: false
      add :description, :string
      add :date, :date, null: false
      add :account_id, references(:accounts, on_delete: :restrict), null: false
      add :provision_id, references(:provisions, on_delete: :restrict), null: false

      # For transfers, we need to track the related transaction
      add :transfer_pair_id, references(:transactions, on_delete: :restrict)

      timestamps()
    end

    # Indexes for common queries
    create index(:transactions, [:account_id])
    create index(:transactions, [:provision_id])
    create index(:transactions, [:date])
    create index(:transactions, [:transfer_pair_id])

    # Table to track monthly balances and rollovers
    create table(:monthly_summaries) do
      add :month, :string, null: false
      add :income, :bigint, null: false, default: 0
      add :provisioned, :bigint, null: false, default: 0
      add :spent, :bigint, null: false, default: 0
      add :rollover, :bigint, null: false, default: 0

      timestamps()
    end

    create unique_index(:monthly_summaries, [:month])
  end

  def down do
    drop table(:monthly_summaries)
    drop table(:transactions)
    drop table(:provisions)
    drop table(:categories)
    drop table(:accounts)
  end
end
