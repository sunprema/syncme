defmodule SyncMe.EventsTest do
  use SyncMe.DataCase

  alias SyncMe.Events

  describe "event_types" do
    alias SyncMe.Events.EventType

    import SyncMe.AccountsFixtures, only: [user_scope_fixture: 0]
    import SyncMe.EventsFixtures

    @invalid_attrs %{name: nil, description: nil, slug: nil, duration_in_minutes: nil, price: nil, is_active: nil}

    test "list_event_types/1 returns all scoped event_types" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      event_type = event_type_fixture(scope)
      other_event_type = event_type_fixture(other_scope)
      assert Events.list_event_types(scope) == [event_type]
      assert Events.list_event_types(other_scope) == [other_event_type]
    end

    test "get_event_type!/2 returns the event_type with given id" do
      scope = user_scope_fixture()
      event_type = event_type_fixture(scope)
      other_scope = user_scope_fixture()
      assert Events.get_event_type!(scope, event_type.id) == event_type
      assert_raise Ecto.NoResultsError, fn -> Events.get_event_type!(other_scope, event_type.id) end
    end

    test "create_event_type/2 with valid data creates a event_type" do
      valid_attrs = %{name: "some name", description: "some description", slug: "some slug", duration_in_minutes: 42, price: "120.5", is_active: true}
      scope = user_scope_fixture()

      assert {:ok, %EventType{} = event_type} = Events.create_event_type(scope, valid_attrs)
      assert event_type.name == "some name"
      assert event_type.description == "some description"
      assert event_type.slug == "some slug"
      assert event_type.duration_in_minutes == 42
      assert event_type.price == Decimal.new("120.5")
      assert event_type.is_active == true
      assert event_type.user_id == scope.user.id
    end

    test "create_event_type/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.create_event_type(scope, @invalid_attrs)
    end

    test "update_event_type/3 with valid data updates the event_type" do
      scope = user_scope_fixture()
      event_type = event_type_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description", slug: "some updated slug", duration_in_minutes: 43, price: "456.7", is_active: false}

      assert {:ok, %EventType{} = event_type} = Events.update_event_type(scope, event_type, update_attrs)
      assert event_type.name == "some updated name"
      assert event_type.description == "some updated description"
      assert event_type.slug == "some updated slug"
      assert event_type.duration_in_minutes == 43
      assert event_type.price == Decimal.new("456.7")
      assert event_type.is_active == false
    end

    test "update_event_type/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      event_type = event_type_fixture(scope)

      assert_raise MatchError, fn ->
        Events.update_event_type(other_scope, event_type, %{})
      end
    end

    test "update_event_type/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      event_type = event_type_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Events.update_event_type(scope, event_type, @invalid_attrs)
      assert event_type == Events.get_event_type!(scope, event_type.id)
    end

    test "delete_event_type/2 deletes the event_type" do
      scope = user_scope_fixture()
      event_type = event_type_fixture(scope)
      assert {:ok, %EventType{}} = Events.delete_event_type(scope, event_type)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event_type!(scope, event_type.id) end
    end

    test "delete_event_type/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      event_type = event_type_fixture(scope)
      assert_raise MatchError, fn -> Events.delete_event_type(other_scope, event_type) end
    end

    test "change_event_type/2 returns a event_type changeset" do
      scope = user_scope_fixture()
      event_type = event_type_fixture(scope)
      assert %Ecto.Changeset{} = Events.change_event_type(scope, event_type)
    end
  end
end
