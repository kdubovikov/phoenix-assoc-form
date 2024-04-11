defmodule ScrumMaster.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias ScrumMaster.Accounts

  schema "teams" do
    field :name, :string
    many_to_many :leaders, ScrumMaster.Accounts.User, join_through: "team_leaders"
    many_to_many :members, ScrumMaster.Accounts.User, join_through: "team_members"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    leaders = Map.get(attrs, :leaders, [])
    members = Map.get(attrs, :members, [])

    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_assoc(:leaders, leaders)
    |> put_assoc(:members, members)
  end

  def handle_member_changeset(changeset, member_ids) do
    members = Accounts.get_users_by_ids(member_ids)

    changeset
    |> put_assoc(:members, members)
    |> validate_at_least_one(:members, "Team must have at least one member")
  end

  def handle_leader_changeset(changeset, leader_ids) do
    leaders = Accounts.get_users_by_ids(leader_ids)

    changeset
    |> put_assoc(:leaders, leaders)
    |> validate_at_least_one(:leaders, "Team must have at least one leader")
  end

  defp validate_at_least_one(changeset, field, error_message) do
    if get_field(changeset, field) |> Enum.count() < 1 do
      add_error(changeset, field, error_message)
    else
      changeset
    end
  end
end
