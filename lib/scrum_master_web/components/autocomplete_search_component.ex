defmodule ScrumMasterWeb.AutocompleteSearchComponent do
  use ScrumMasterWeb, :live_component

  attr :docs, :list, required: true
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.search_input value={@query} phx-target={@myself} phx-keyup="do-search" phx-debounce="200" />
      <.search_results :if={@show} docs={@results} myself={@myself} />
    </div>
    """
  end

  def search_results(assigns) do
    ~H"""
    <div class="relative">
      <ul class="absolute z-10 w-full bg-white rounded shadow-lg">
        <%= for doc <- @docs do %>
          <.result_item doc={doc} myself={@myself} />
        <% end %>
      </ul>
    </div>
    """
  end

  attr :doc, :map, required: true

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
    >
      <%= @doc.email %>
    </li>
    """
  end

  attr :rest, :global
  attr :value, :string, default: ""

  def search_input(assigns) do
    ~H"""
    <div class="relative ">
      <!-- Heroicon name: mini/magnifying-glass -->
      <input
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

  def handle_event("select-item", %{"email" => email}, socket) do
    IO.puts("Selected item: #{email}")
    {:noreply, assign(socket, query: email, results: [])}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:documents, [])
     |> assign(:search, "")}
  end
end
