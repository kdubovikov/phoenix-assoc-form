defmodule ScrumMasterWeb.AutocompleteSearchComponent do
  use ScrumMasterWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.search_modal :if={@show} id="search-modal" show on_cancel={@on_cancel}>
        <.search_input value={@query} phx-target={@myself} phx-keyup="do-search" phx-debounce="200" />
        <.search_results docs={@results} />
      </.search_modal>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def search_modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-zinc-50/90 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full justify-center">
          <div class="w-full min-h-12 max-w-3xl p-2 sm:p-4 lg:py-6">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="hidden relative rounded-2xl bg-white p-2 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition min-h-[30vh] max-h-[50vh] overflow-y-scroll"
            >
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :docs, :list, required: true

  def search_results(assigns) do
    ~H"""
    <ul class="-mb-2 py-2 text-sm text-gray-800 flex space-y-2 flex-col" id="options" role="listbox">
      <li
        :if={@docs == []}
        id="option-none"
        role="option"
        tabindex="-1"
        class="cursor-default select-none rounded-md px-4 py-2 text-xl"
      >
        No Results
      </li>

      <.link :for={doc <- @docs} navigate={~p"/documents/#{doc.id}"} id={"doc-#{doc.id}"}>
        <.result_item doc={doc} />
      </.link>
    </ul>
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
    >
      <!-- svg of a document -->
      <div>
        <%= @doc.email %>
      </div>
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
        %{"value" => value, "search_fun" => search_fun, "context" => context},
        socket
      ) do
    documents = apply(context, search_fun, [value, socket.assigns.documents])

    {:noreply,
     socket
     |> assign(:search, value)
     |> assign(:documents, documents)}
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
