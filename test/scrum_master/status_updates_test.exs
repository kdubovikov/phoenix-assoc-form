defmodule ScrumMaster.StatusUpdatesTest do
  use ScrumMaster.DataCase

  alias ScrumMaster.StatusUpdates

  describe "status_updates" do
    alias ScrumMaster.StatusUpdates.StatusUpdate

    import ScrumMaster.StatusUpdatesFixtures

    @invalid_attrs %{progress: nil, comments: nil, blockers: nil, plans: nil}

    test "list_status_updates/0 returns all status_updates" do
      status_update = status_update_fixture()
      assert StatusUpdates.list_status_updates() == [status_update]
    end

    test "get_status_update!/1 returns the status_update with given id" do
      status_update = status_update_fixture()
      assert StatusUpdates.get_status_update!(status_update.id) == status_update
    end

    test "create_status_update/1 with valid data creates a status_update" do
      valid_attrs = %{progress: "some progress", comments: "some comments", blockers: "some blockers", plans: "some plans"}

      assert {:ok, %StatusUpdate{} = status_update} = StatusUpdates.create_status_update(valid_attrs)
      assert status_update.progress == "some progress"
      assert status_update.comments == "some comments"
      assert status_update.blockers == "some blockers"
      assert status_update.plans == "some plans"
    end

    test "create_status_update/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StatusUpdates.create_status_update(@invalid_attrs)
    end

    test "update_status_update/2 with valid data updates the status_update" do
      status_update = status_update_fixture()
      update_attrs = %{progress: "some updated progress", comments: "some updated comments", blockers: "some updated blockers", plans: "some updated plans"}

      assert {:ok, %StatusUpdate{} = status_update} = StatusUpdates.update_status_update(status_update, update_attrs)
      assert status_update.progress == "some updated progress"
      assert status_update.comments == "some updated comments"
      assert status_update.blockers == "some updated blockers"
      assert status_update.plans == "some updated plans"
    end

    test "update_status_update/2 with invalid data returns error changeset" do
      status_update = status_update_fixture()
      assert {:error, %Ecto.Changeset{}} = StatusUpdates.update_status_update(status_update, @invalid_attrs)
      assert status_update == StatusUpdates.get_status_update!(status_update.id)
    end

    test "delete_status_update/1 deletes the status_update" do
      status_update = status_update_fixture()
      assert {:ok, %StatusUpdate{}} = StatusUpdates.delete_status_update(status_update)
      assert_raise Ecto.NoResultsError, fn -> StatusUpdates.get_status_update!(status_update.id) end
    end

    test "change_status_update/1 returns a status_update changeset" do
      status_update = status_update_fixture()
      assert %Ecto.Changeset{} = StatusUpdates.change_status_update(status_update)
    end
  end
end
