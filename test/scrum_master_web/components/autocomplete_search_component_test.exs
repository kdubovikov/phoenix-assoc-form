defmodule ScrumMasterWeb.AutocompleteSearchComponentTes do
  use ScrumMasterWeb.ConnCase
  alias ScrumMasterWeb.AutocompleteSearchComponent
  import Phoenix.LiveViewTest
  alias Phoenix.LiveView.JS

  def mock_search_fun(value, documents) do
    Enum.filter(documents, fn doc -> String.contains?(doc, value) end)
  end

  setup do
    # Create test variables
    documents = ["Document 1", "Document 2", "Document 3"]

    # Return the test variables
    {:ok,
     %{
       documents: documents,
       search_fun: :mock_search_fun,
       context: ScrumMasterWeb.AutocompleteSearchComponent
     }}
  end

  @tag :autocomplete
  test "it renders the component", %{
    conn: conn,
    documents: documents,
    search_fun: search_fun,
    context: context
  } do
    on_cancel = %JS{}

    html =
      render_component(AutocompleteSearchComponent, %{
        id: "search-modal",
        documents: documents,
        search_fun: search_fun,
        context: context,
        search: "",
        show: true,
        on_cancel: on_cancel,
        query: "",
        results: []
      })

    assert html =~ "Search"
  end

  @tag :autocomplete
  test "it filters documents by using query", %{
    conn: conn,
    documents: documents,
    search_fun: search_fun,
    context: context
  } do
    on_cancel = %JS{}

    query = "Document 1"
    expected_results = ["Document 1"]

    html =
      render_component(AutocompleteSearchComponent, %{
        id: "search-modal",
        documents: documents,
        search_fun: search_fun,
        context: context,
        search: query,
        show: true,
        on_cancel: on_cancel,
        query: query,
        results: []
      })

    assert html =~ "Search"
    assert html =~ "Document 1"
    refute html =~ "Document 2"
    refute html =~ "Document 3"
  end
end
