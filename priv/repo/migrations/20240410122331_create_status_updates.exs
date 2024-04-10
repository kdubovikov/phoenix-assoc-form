defmodule ScrumMaster.Repo.Migrations.CreateStatusUpdates do
  use Ecto.Migration

  def change do
    create table(:status_updates) do
      add :progress, :string
      add :blockers, :string
      add :plans, :string
      add :comments, :string

      timestamps(type: :utc_datetime)
    end
  end
end
