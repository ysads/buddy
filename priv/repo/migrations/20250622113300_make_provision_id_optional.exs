defmodule Buddy.Repo.Migrations.MakeProvisionIdOptional do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      modify :provision_id,
             references(:provisions, on_delete: :restrict),
             null: true,
             from: {references(:provisions, on_delete: :restrict), null: false}
    end
  end
end
