defmodule Buddy.Repo.Migrations.AddTransactionType do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :type, :string, null: false
    end
  end
end
