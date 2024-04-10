defmodule ScrumMaster.StatusUpdates.StatusUpdate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "status_updates" do
    field :progress, :string
    field :comments, :string
    field :blockers, :string
    field :plans, :string

    belongs_to :user, ScrumMaster.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(status_update, attrs) do
    status_update
    |> cast(attrs, [:progress, :blockers, :plans, :comments])
    |> validate_required([:progress, :blockers, :plans, :comments])
  end
end
