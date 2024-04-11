defmodule ScrumMaster.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    many_to_many :leaders, ScrumMaster.Users.User, join_through: "team_leaders"
    many_to_many :members, ScrumMaster.Users.User, join_through: "team_members"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_at_least_one(:leaders, "Team must have at least one leader")
    |> validate_at_least_one(:members, "Team must have at least one member")
  end

  defp validate_at_least_one(changeset, field, error_message) do
    if get_field(changeset, field) |> Enum.count() < 1 do
      add_error(changeset, field, error_message)
    else
      changeset
    end
  end
end
