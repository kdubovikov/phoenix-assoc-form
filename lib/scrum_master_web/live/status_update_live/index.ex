defmodule ScrumMasterWeb.StatusUpdateLive.Index do
  use ScrumMasterWeb, :live_view

  alias ScrumMaster.StatusUpdates
  alias ScrumMaster.StatusUpdates.StatusUpdate

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :status_updates, StatusUpdates.list_status_updates())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Status update")
    |> assign(:status_update, StatusUpdates.get_status_update!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Status update")
    |> assign(:status_update, %StatusUpdate{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Status updates")
    |> assign(:status_update, nil)
  end

  @impl true
  def handle_info({ScrumMasterWeb.StatusUpdateLive.FormComponent, {:saved, status_update}}, socket) do
    {:noreply, stream_insert(socket, :status_updates, status_update)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    status_update = StatusUpdates.get_status_update!(id)
    {:ok, _} = StatusUpdates.delete_status_update(status_update)

    {:noreply, stream_delete(socket, :status_updates, status_update)}
  end
end
