defmodule ScrumMasterWeb.StatusUpdateLive.Show do
  use ScrumMasterWeb, :live_view

  alias ScrumMaster.StatusUpdates

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:status_update, StatusUpdates.get_status_update!(id))}
  end

  defp page_title(:show), do: "Show Status update"
  defp page_title(:edit), do: "Edit Status update"
end
