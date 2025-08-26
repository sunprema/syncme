defmodule SyncMe.PartnersTest do
  use SyncMe.DataCase

  alias SyncMe.Partners

  describe "partners" do
    alias SyncMe.Partners.Partner

    import SyncMe.AccountsFixtures, only: [user_scope_fixture: 0]
    import SyncMe.PartnersFixtures

    @invalid_attrs %{bio: nil, syncme_link: nil}

    test "list_partners/1 returns all scoped partners" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      partner = partner_fixture(scope)
      other_partner = partner_fixture(other_scope)
      assert Partners.list_partners(scope) == [partner]
      assert Partners.list_partners(other_scope) == [other_partner]
    end

    test "get_partner!/2 returns the partner with given id" do
      scope = user_scope_fixture()
      partner = partner_fixture(scope)
      other_scope = user_scope_fixture()
      assert Partners.get_partner!(scope, partner.id) == partner
      assert_raise Ecto.NoResultsError, fn -> Partners.get_partner!(other_scope, partner.id) end
    end

    test "create_partner/2 with valid data creates a partner" do
      valid_attrs = %{bio: "some bio", syncme_link: "some syncme_link"}
      scope = user_scope_fixture()

      assert {:ok, %Partner{} = partner} = Partners.create_partner(scope, valid_attrs)
      assert partner.bio == "some bio"
      assert partner.syncme_link == "some syncme_link"
      assert partner.user_id == scope.user.id
    end

    test "create_partner/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Partners.create_partner(scope, @invalid_attrs)
    end

    test "update_partner/3 with valid data updates the partner" do
      scope = user_scope_fixture()
      partner = partner_fixture(scope)
      update_attrs = %{bio: "some updated bio", syncme_link: "some updated syncme_link"}

      assert {:ok, %Partner{} = partner} = Partners.update_partner(scope, partner, update_attrs)
      assert partner.bio == "some updated bio"
      assert partner.syncme_link == "some updated syncme_link"
    end

    test "update_partner/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      partner = partner_fixture(scope)

      assert_raise MatchError, fn ->
        Partners.update_partner(other_scope, partner, %{})
      end
    end

    test "update_partner/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      partner = partner_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Partners.update_partner(scope, partner, @invalid_attrs)
      assert partner == Partners.get_partner!(scope, partner.id)
    end

    test "delete_partner/2 deletes the partner" do
      scope = user_scope_fixture()
      partner = partner_fixture(scope)
      assert {:ok, %Partner{}} = Partners.delete_partner(scope, partner)
      assert_raise Ecto.NoResultsError, fn -> Partners.get_partner!(scope, partner.id) end
    end

    test "delete_partner/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      partner = partner_fixture(scope)
      assert_raise MatchError, fn -> Partners.delete_partner(other_scope, partner) end
    end

    test "change_partner/2 returns a partner changeset" do
      scope = user_scope_fixture()
      partner = partner_fixture(scope)
      assert %Ecto.Changeset{} = Partners.change_partner(scope, partner)
    end
  end
end
