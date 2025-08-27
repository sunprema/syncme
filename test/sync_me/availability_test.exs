defmodule SyncMe.AvailabilityTest do
  use SyncMe.DataCase

  alias SyncMe.Availability

  describe "availability_rules" do
    alias SyncMe.Availability.AvailabilityRule

    import SyncMe.AccountsFixtures, only: [user_scope_fixture: 0]
    import SyncMe.AvailabilityFixtures

    @invalid_attrs %{day_of_week: nil, start_time: nil, end_time: nil}

    test "list_availability_rules/1 returns all scoped availability_rules" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      availability_rule = availability_rule_fixture(scope)
      other_availability_rule = availability_rule_fixture(other_scope)
      assert Availability.list_availability_rules(scope) == [availability_rule]
      assert Availability.list_availability_rules(other_scope) == [other_availability_rule]
    end

    test "get_availability_rule!/2 returns the availability_rule with given id" do
      scope = user_scope_fixture()
      availability_rule = availability_rule_fixture(scope)
      other_scope = user_scope_fixture()
      assert Availability.get_availability_rule!(scope, availability_rule.id) == availability_rule
      assert_raise Ecto.NoResultsError, fn -> Availability.get_availability_rule!(other_scope, availability_rule.id) end
    end

    test "create_availability_rule/2 with valid data creates a availability_rule" do
      valid_attrs = %{day_of_week: 42, start_time: ~T[14:00:00], end_time: ~T[14:00:00]}
      scope = user_scope_fixture()

      assert {:ok, %AvailabilityRule{} = availability_rule} = Availability.create_availability_rule(scope, valid_attrs)
      assert availability_rule.day_of_week == 42
      assert availability_rule.start_time == ~T[14:00:00]
      assert availability_rule.end_time == ~T[14:00:00]
      assert availability_rule.user_id == scope.user.id
    end

    test "create_availability_rule/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Availability.create_availability_rule(scope, @invalid_attrs)
    end

    test "update_availability_rule/3 with valid data updates the availability_rule" do
      scope = user_scope_fixture()
      availability_rule = availability_rule_fixture(scope)
      update_attrs = %{day_of_week: 43, start_time: ~T[15:01:01], end_time: ~T[15:01:01]}

      assert {:ok, %AvailabilityRule{} = availability_rule} = Availability.update_availability_rule(scope, availability_rule, update_attrs)
      assert availability_rule.day_of_week == 43
      assert availability_rule.start_time == ~T[15:01:01]
      assert availability_rule.end_time == ~T[15:01:01]
    end

    test "update_availability_rule/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      availability_rule = availability_rule_fixture(scope)

      assert_raise MatchError, fn ->
        Availability.update_availability_rule(other_scope, availability_rule, %{})
      end
    end

    test "update_availability_rule/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      availability_rule = availability_rule_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Availability.update_availability_rule(scope, availability_rule, @invalid_attrs)
      assert availability_rule == Availability.get_availability_rule!(scope, availability_rule.id)
    end

    test "delete_availability_rule/2 deletes the availability_rule" do
      scope = user_scope_fixture()
      availability_rule = availability_rule_fixture(scope)
      assert {:ok, %AvailabilityRule{}} = Availability.delete_availability_rule(scope, availability_rule)
      assert_raise Ecto.NoResultsError, fn -> Availability.get_availability_rule!(scope, availability_rule.id) end
    end

    test "delete_availability_rule/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      availability_rule = availability_rule_fixture(scope)
      assert_raise MatchError, fn -> Availability.delete_availability_rule(other_scope, availability_rule) end
    end

    test "change_availability_rule/2 returns a availability_rule changeset" do
      scope = user_scope_fixture()
      availability_rule = availability_rule_fixture(scope)
      assert %Ecto.Changeset{} = Availability.change_availability_rule(scope, availability_rule)
    end
  end
end
