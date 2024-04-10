defmodule ScrumMasterWeb.StatusUpdateLiveTest do
  use ScrumMasterWeb.ConnCase

  import Phoenix.LiveViewTest
  import ScrumMaster.StatusUpdatesFixtures

  @create_attrs %{progress: "some progress", comments: "some comments", blockers: "some blockers", plans: "some plans"}
  @update_attrs %{progress: "some updated progress", comments: "some updated comments", blockers: "some updated blockers", plans: "some updated plans"}
  @invalid_attrs %{progress: nil, comments: nil, blockers: nil, plans: nil}

  defp create_status_update(_) do
    status_update = status_update_fixture()
    %{status_update: status_update}
  end

  describe "Index" do
    setup [:create_status_update]

    test "lists all status_updates", %{conn: conn, status_update: status_update} do
      {:ok, _index_live, html} = live(conn, ~p"/status_updates")

      assert html =~ "Listing Status updates"
      assert html =~ status_update.progress
    end

    test "saves new status_update", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/status_updates")

      assert index_live |> element("a", "New Status update") |> render_click() =~
               "New Status update"

      assert_patch(index_live, ~p"/status_updates/new")

      assert index_live
             |> form("#status_update-form", status_update: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#status_update-form", status_update: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/status_updates")

      html = render(index_live)
      assert html =~ "Status update created successfully"
      assert html =~ "some progress"
    end

    test "updates status_update in listing", %{conn: conn, status_update: status_update} do
      {:ok, index_live, _html} = live(conn, ~p"/status_updates")

      assert index_live |> element("#status_updates-#{status_update.id} a", "Edit") |> render_click() =~
               "Edit Status update"

      assert_patch(index_live, ~p"/status_updates/#{status_update}/edit")

      assert index_live
             |> form("#status_update-form", status_update: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#status_update-form", status_update: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/status_updates")

      html = render(index_live)
      assert html =~ "Status update updated successfully"
      assert html =~ "some updated progress"
    end

    test "deletes status_update in listing", %{conn: conn, status_update: status_update} do
      {:ok, index_live, _html} = live(conn, ~p"/status_updates")

      assert index_live |> element("#status_updates-#{status_update.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#status_updates-#{status_update.id}")
    end
  end

  describe "Show" do
    setup [:create_status_update]

    test "displays status_update", %{conn: conn, status_update: status_update} do
      {:ok, _show_live, html} = live(conn, ~p"/status_updates/#{status_update}")

      assert html =~ "Show Status update"
      assert html =~ status_update.progress
    end

    test "updates status_update within modal", %{conn: conn, status_update: status_update} do
      {:ok, show_live, _html} = live(conn, ~p"/status_updates/#{status_update}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Status update"

      assert_patch(show_live, ~p"/status_updates/#{status_update}/show/edit")

      assert show_live
             |> form("#status_update-form", status_update: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#status_update-form", status_update: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/status_updates/#{status_update}")

      html = render(show_live)
      assert html =~ "Status update updated successfully"
      assert html =~ "some updated progress"
    end
  end
end
