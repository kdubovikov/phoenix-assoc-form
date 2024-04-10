defmodule ScrumMasterWeb.StatusUpdateLive.FormComponent do
  use ScrumMasterWeb, :live_component

  alias ScrumMaster.StatusUpdates

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage status_update records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="status_update-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:progress]} type="text" label="Progress" />
        <.input field={@form[:blockers]} type="text" label="Blockers" />
        <.input field={@form[:plans]} type="text" label="Plans" />
        <.input field={@form[:comments]} type="text" label="Comments" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Status update</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{status_update: status_update} = assigns, socket) do
    changeset = StatusUpdates.change_status_update(status_update)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"status_update" => status_update_params}, socket) do
    changeset =
      socket.assigns.status_update
      |> StatusUpdates.change_status_update(status_update_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"status_update" => status_update_params}, socket) do
    save_status_update(socket, socket.assigns.action, status_update_params)
  end

  defp save_status_update(socket, :edit, status_update_params) do
    case StatusUpdates.update_status_update(socket.assigns.status_update, status_update_params) do
      {:ok, status_update} ->
        notify_parent({:saved, status_update})

        {:noreply,
         socket
         |> put_flash(:info, "Status update updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_status_update(socket, :new, status_update_params) do
    case StatusUpdates.create_status_update(status_update_params) do
      {:ok, status_update} ->
        notify_parent({:saved, status_update})

        {:noreply,
         socket
         |> put_flash(:info, "Status update created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
