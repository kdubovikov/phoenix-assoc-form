defmodule ScrumMasterWeb.TeamLive.Index do
  use ScrumMasterWeb, :live_view

  alias ScrumMaster.Teams
  alias ScrumMaster.Teams.Team
  alias ScrumMaster.Accounts

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:teams, Teams.list_teams())
      |> stream(:users, Accounts.list_users())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Team")
    |> assign(:team, Teams.get_team!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Team")
    |> assign(:team, %Team{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Teams")
    |> assign(:team, nil)
  end

  @impl true
  def handle_info({ScrumMasterWeb.TeamLive.FormComponent, {:saved, team}}, socket) do
    {:noreply, stream_insert(socket, :teams, team)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Teams.get_team!(id)
    {:ok, _} = Teams.delete_team(team)

    {:noreply, stream_delete(socket, :teams, team)}
  end
end
