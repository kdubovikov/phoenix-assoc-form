defmodule ScrumMaster.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create table(:team_leaders) do
      add :team_id, references(:teams, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create table(:team_members) do
      add :team_id, references(:teams, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:team_leaders, [:team_id, :user_id], unique: true)
    create index(:team_members, [:team_id, :user_id], unique: true)
  end
end
