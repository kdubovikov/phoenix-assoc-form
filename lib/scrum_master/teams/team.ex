defmodule ScrumMaster.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
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
    |> handle_leader_changeset(leaders)
    |> put_assoc(:leaders, leaders)
    |> handle_member_changeset(members)
    |> put_assoc(:members, members)
  end

  def handle_member_changeset(changeset, member_ids) do
    members = Accounts.get_users_by_ids(member_ids)

    changeset
    |> validate_at_least_one(:members, "Team must have at least one member")
    |> validate_non_empty_email(:members, "Members must have a non-empty email")
    |> validate_unique_email(:members, "Members must have unique emails")
    |> put_assoc(:members, members)
  end

  def handle_leader_changeset(changeset, leader_ids) do
    leaders = Accounts.get_users_by_ids(leader_ids)

    changeset
    |> validate_at_least_one(:leaders, "Team must have at least one leader")
    |> validate_non_empty_email(:leaders, "Leaders must have a non-empty email")
    |> validate_unique_email(:leaders, "Leaders must have unique emails")
    |> put_assoc(:leaders, leaders)
  end

  defp validate_at_least_one(changeset, field, error_message) do
    if get_field(changeset, field) |> Enum.count() < 1 do
      add_error(changeset, field, error_message)
    else
      changeset
    end
  end

  defp validate_non_empty_email(changeset, field, error_message) do
    Logger.debug("Validating non-empty email")

    if get_field(changeset, field) |> Enum.all?(&(&1.email != "")) do
      Logger.debug("All emails are non-empty")
      changeset
    else
      add_error(changeset, field, error_message)
    end
  end

  defp validate_unique_email(changeset, field, error_message) do
    Logger.debug("Validating unique email")
    field = get_field(changeset, field)

    if field |> Enum.uniq_by(& &1.email) |> Enum.count() == field do
      Logger.debug("All emails are unique", field)
      changeset
    else
      Logger.debug("ERR Some emails are not unique", field)
      add_error(changeset, field, error_message)
    end
  end
end
