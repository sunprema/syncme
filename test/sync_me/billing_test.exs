defmodule SyncMe.BillingTest do
  use SyncMe.DataCase

  alias SyncMe.Billing

  describe "transactions" do
    alias SyncMe.Billing.Transaction

    import SyncMe.AccountsFixtures, only: [user_scope_fixture: 0]
    import SyncMe.BillingFixtures

    @invalid_attrs %{
      status: nil,
      total_amount_charged: nil,
      platform_fee: nil,
      partner_payout_amount: nil,
      referral_payout_amount: nil,
      payment_gateway_id: nil
    }

    test "list_transactions/1 returns all scoped transactions" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      other_transaction = transaction_fixture(other_scope)
      assert Billing.list_transactions(scope) == [transaction]
      assert Billing.list_transactions(other_scope) == [other_transaction]
    end

    test "get_transaction!/2 returns the transaction with given id" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      other_scope = user_scope_fixture()
      assert Billing.get_transaction!(scope, transaction.id) == transaction

      assert_raise Ecto.NoResultsError, fn ->
        Billing.get_transaction!(other_scope, transaction.id)
      end
    end

    test "create_transaction/2 with valid data creates a transaction" do
      valid_attrs = %{
        status: "some status",
        total_amount_charged: "120.5",
        platform_fee: "120.5",
        partner_payout_amount: "120.5",
        referral_payout_amount: "120.5",
        payment_gateway_id: "some payment_gateway_id"
      }

      scope = user_scope_fixture()

      assert {:ok, %Transaction{} = transaction} = Billing.create_transaction(scope, valid_attrs)
      assert transaction.status == "some status"
      assert transaction.total_amount_charged == Decimal.new("120.5")
      assert transaction.platform_fee == Decimal.new("120.5")
      assert transaction.partner_payout_amount == Decimal.new("120.5")
      assert transaction.referral_payout_amount == Decimal.new("120.5")
      assert transaction.payment_gateway_id == "some payment_gateway_id"
      assert transaction.user_id == scope.user.id
    end

    test "create_transaction/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.create_transaction(scope, @invalid_attrs)
    end

    test "update_transaction/3 with valid data updates the transaction" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)

      update_attrs = %{
        status: "some updated status",
        total_amount_charged: "456.7",
        platform_fee: "456.7",
        partner_payout_amount: "456.7",
        referral_payout_amount: "456.7",
        payment_gateway_id: "some updated payment_gateway_id"
      }

      assert {:ok, %Transaction{} = transaction} =
               Billing.update_transaction(scope, transaction, update_attrs)

      assert transaction.status == "some updated status"
      assert transaction.total_amount_charged == Decimal.new("456.7")
      assert transaction.platform_fee == Decimal.new("456.7")
      assert transaction.partner_payout_amount == Decimal.new("456.7")
      assert transaction.referral_payout_amount == Decimal.new("456.7")
      assert transaction.payment_gateway_id == "some updated payment_gateway_id"
    end

    test "update_transaction/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)

      assert_raise MatchError, fn ->
        Billing.update_transaction(other_scope, transaction, %{})
      end
    end

    test "update_transaction/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Billing.update_transaction(scope, transaction, @invalid_attrs)

      assert transaction == Billing.get_transaction!(scope, transaction.id)
    end

    test "delete_transaction/2 deletes the transaction" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert {:ok, %Transaction{}} = Billing.delete_transaction(scope, transaction)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_transaction!(scope, transaction.id) end
    end

    test "delete_transaction/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert_raise MatchError, fn -> Billing.delete_transaction(other_scope, transaction) end
    end

    test "change_transaction/2 returns a transaction changeset" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert %Ecto.Changeset{} = Billing.change_transaction(scope, transaction)
    end
  end
end
