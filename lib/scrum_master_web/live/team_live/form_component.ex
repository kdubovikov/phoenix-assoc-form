defmodule ScrumMasterWeb.TeamLive.FormComponent do
  require Logger
  use ScrumMasterWeb, :live_component

  alias ScrumMaster.Teams
  alias ScrumMaster.Accounts
  import Ecto.Changeset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage team records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="team-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.live_component
          module={ScrumMasterWeb.AutocompleteSearchComponent}
          field={@form[:leaders]}
          id="team-lead-search"
          label="Team Lead"
          show={true}
          on_cancel={JS.hide(to: "#team-lead-search")}
          search_fun={:search_users_by_email}
          context={Accounts}
          results={[]}
          selected={[]}
          parent={@myself}
        />

        <.live_component
          module={ScrumMasterWeb.AutocompleteSearchComponent}
          field={@form[:members]}
          id="team-member-search"
          label="Members"
          show={true}
          on_cancel={JS.hide(to: "#team-member-search")}
          search_fun={:search_users_by_email}
          context={Accounts}
          results={[]}
          selected={[]}
          parent={@myself}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Team</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{team: team} = assigns, socket) do
    changeset = Teams.change_team(team)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"team" => team_params}, socket) do
    Logger.info("Validating team with #{inspect(team_params)}")

    changeset =
      socket.assigns.team
      |> Teams.change_team(team_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    Logger.info("Saving #{socket.assigns.action} team")
    save_team(socket, socket.assigns.action, team_params)
  end

  def handle_event("team-lead-search-add", _, socket) do
    Logger.debug("Adding leader to team")
    Logger.debug(inspect(socket.assigns.form))
    # add a new empty user to the leaders list
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_field(changeset, :leaders)
        changeset = Ecto.Changeset.put_change(changeset, :leaders, [%{}] ++ existing)
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("team-member-search-add", _, socket) do
    Logger.debug("Adding member to team")

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_field(changeset, :members)
        changeset = Ecto.Changeset.put_change(changeset, :members, [%{}] ++ existing)
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  defp save_team(socket, :edit, team_params) do
    case Teams.update_team(socket.assigns.team, team_params) do
      {:ok, team} ->
        notify_parent({:saved, team})

        {:noreply,
         socket
         |> put_flash(:info, "Team updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_team(socket, :new, team_params) do
    case Teams.create_team(team_params) do
      {:ok, team} ->
        notify_parent({:saved, team})

        {:noreply,
         socket
         |> put_flash(:info, "Team created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.debug("Error: #{inspect(changeset)}")
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form =
      changeset
      |> ensure_association_present(:leaders, %Accounts.User{})
      |> ensure_association_present(:members, %Accounts.User{})
      |> to_form

    Logger.debug("Form: #{inspect(form)}")
    assign(socket, :form, form)
  end

  defp ensure_association_present(changeset, field, default_value) do
    if get_field(changeset, field) == [] do
      put_change(changeset, field, [default_value])
    else
      changeset
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
