defmodule ScrumMasterWeb.AutocompleteSearchComponent do
  require Logger
  use ScrumMasterWeb, :live_component
  alias ScrumMaster.Accounts

  attr :label, :string, required: true
  attr :field, :map, required: true
  attr :results, :list, default: []
  attr :parent, :map, required: true
  @impl true
  def render(assigns) do
    IO.puts("Query on rendering: #{inspect(assigns.query)}")

    ~H"""
    <div>
      <label for="search-input"><%= @label %></label>
      <.inputs_for :let={item} field={@field}>
        <.search_input
          field={item[:email]}
          value={@query[item.index]}
          phx-target={@myself}
          phx-keyup="do-search"
          phx-debounce="200"
        />
        <.search_results :if={@show} docs={@results} myself={@myself} index={item.index} />
      </.inputs_for>
      <a href="#" phx-click={@id <> "-add"} phx-target={@parent}>Add more</a>
    </div>
    """
  end

  attr :docs, :list, required: true
  attr :myself, :map, required: true
  attr :index, :integer, required: true

  def search_results(assigns) do
    ~H"""
    <div class="relative">
      <ul class="absolute z-10 w-full bg-white rounded shadow-lg">
        <%= for doc <- @docs do %>
          <.result_item doc={doc} myself={@myself} index={@index} />
        <% end %>
      </ul>
    </div>
    """
  end

  attr :doc, :map, required: true
  attr :index, :integer, required: true
  attr :myself, :map, required: true

  def result_item(assigns) do
    ~H"""
    <li
      class="cursor-default select-none rounded-md px-4 py-2 text-xl bg-zinc-100 hover:bg-zinc-800 hover:text-white hover:cursor-pointer flex flex-row space-x-2 items-center"
      id={"option-#{@doc.id}"}
      role="option"
      tabindex="-1"
      phx-click="select-item"
      phx-target={@myself}
      phx-value-email={@doc.email}
      phx-value-index={@index}
    >
      <%= @doc.email %>
    </li>
    """
  end

  attr :rest, :global
  attr :value, :string, default: ""
  attr :field, :map, required: true

  def search_input(assigns) do
    ~H"""
    <div class="relative ">
      <!-- Heroicon name: mini/magnifying-glass -->
      <.input
        field={@field}
        {@rest}
        type="text"
        value={@value}
        class="h-12 w-full border-none focus:ring-0 pl-11 pr-4 text-gray-800 placeholder-gray-400 sm:text-sm"
        placeholder="Search ..."
        role="combobox"
        aria-expanded="false"
        aria-controls="options"
      />
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [docs: []]}
  end

  @impl true
  def handle_event(
        "do-search",
        %{"value" => value},
        socket
      ) do
    if String.trim(value) != "" do
      IO.puts("Searching users with: #{value}")
      search_fun = socket.assigns.search_fun
      context = socket.assigns.context

      results = apply(context, search_fun, [value])

      IO.inspect(results)

      {:noreply,
       socket
       |> assign(:search, value)
       |> assign(:results, results)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("select-item", %{"email" => email, "index" => index}, socket) do
    IO.puts("Selected item: #{email}")
    user = Accounts.get_user_by_email(email)

    query = Map.put(socket.assigns.query, String.to_integer(index), email)
    IO.puts("Updating Query on event: #{inspect(query)}")

    {:noreply, assign(socket, query: query, results: [], selected: [user])}
  end

  @impl true
  def update(assigns, socket) do
    current_query = Map.get(assigns, :query, %{0 => ""})
    IO.puts("Current query: #{inspect(current_query)}")
    updated_assigns = Map.put(assigns, :query, current_query)
    {:ok, assign(socket, updated_assigns)}
  end
end
