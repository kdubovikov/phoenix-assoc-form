defmodule ScrumMaster.StatusUpdatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ScrumMaster.StatusUpdates` context.
  """

  @doc """
  Generate a status_update.
  """
  def status_update_fixture(attrs \\ %{}) do
    {:ok, status_update} =
      attrs
      |> Enum.into(%{
        blockers: "some blockers",
        comments: "some comments",
        plans: "some plans",
        progress: "some progress"
      })
      |> ScrumMaster.StatusUpdates.create_status_update()

    status_update
  end
end
