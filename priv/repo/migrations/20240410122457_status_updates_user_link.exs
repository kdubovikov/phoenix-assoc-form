defmodule ScrumMaster.Repo.Migrations.StatusUpdatesUserLink do
  use Ecto.Migration

  def change do
    alter table(:status_updates) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
