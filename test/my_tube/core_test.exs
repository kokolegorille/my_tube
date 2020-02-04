defmodule MyTube.CoreTest do
  use MyTube.DataCase

  alias MyTube.Core

  describe "events" do
    alias MyTube.Core.Event

    @valid_attrs %{medium: "some medium", medium_uuid: "some medium_uuid", title: "some title"}
    @update_attrs %{medium: "some updated medium", medium_uuid: "some updated medium_uuid", title: "some updated title"}
    @invalid_attrs %{medium: nil, medium_uuid: nil, title: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Core.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Core.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Core.create_event(@valid_attrs)
      assert event.medium == "some medium"
      assert event.medium_uuid == "some medium_uuid"
      assert event.title == "some title"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, %Event{} = event} = Core.update_event(event, @update_attrs)
      assert event.medium == "some updated medium"
      assert event.medium_uuid == "some updated medium_uuid"
      assert event.title == "some updated title"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_event(event, @invalid_attrs)
      assert event == Core.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Core.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Core.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Core.change_event(event)
    end
  end
end
