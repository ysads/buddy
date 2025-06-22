defmodule Buddy.Repo.Migrations.RenameTransactionDate do
  use Ecto.Migration

  def up do
    alter table(:transactions) do
      remove :date
      add :reference_at, :utc_datetime, null: false
    end

    create index(:transactions, [:reference_at])
  end

  def down do
    drop index(:transactions, [:reference_at])

    alter table(:transactions) do
      remove :reference_at
      add :date, :date, null: false
    end
  end
end
