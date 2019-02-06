require 'test_helper'
class ChargesControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Gravatarへのリクエストmock
    stub_request(:get, /https:\/\/ja\.gravatar\.com\/.*\.json/).to_return(status: 200, body: File.read("test/fixtures/files/gravatar.json"))
  end

  ########################################################################
  # new
  ########################################################################
  test "access_new_when_guest" do
    get new_charge_path
    assert_redirected_to login_path
  end

  test "access_new_when_no_charge" do
    user = users(:user4)
    login_user(user)
    get new_charge_path
    assert_response :success
  end

  test "access_new_when_charge_active" do
    user = users(:user1)
    login_user(user)
    get new_charge_path
    assert_redirected_to pro_root_path
  end

  test "access_new_when_charge_cancel_planned" do
    user = users(:user3)
    login_user(user)
    get new_charge_path
    assert_redirected_to pro_root_path
  end

  test "access_new_when_charge_canceled" do
    user = users(:user2)
    login_user(user)
    get new_charge_path
    assert_response :success
  end

  test "access_new_when_charge_without_subscription" do
    user = users(:user5)
    login_user(user)
    get new_charge_path
    assert_response :success
  end



  ########################################################################
  # edit
  ########################################################################
  test "access_edit_when_guest" do
    user = users(:user1)
    get edit_charge_path(user.charge)
    assert_redirected_to login_path
  end

  test "access_edit_when_other" do
    user1 = users(:user1)
    user2 = users(:user2)
    login_user(user2)
    get edit_charge_path(user1.charge)
    assert_redirected_to pro_root_path
  end

  test "access_edit_when_owner" do
    user1 = users(:user1)
    login_user(user1)
    get edit_charge_path(user1.charge)
    assert_response :success
  end



  ########################################################################
  # update_payment
  ########################################################################
  test "access_update_payment_when_guest" do
    get update_payment_charges_path
    assert_redirected_to login_path
  end

  test "access_update_payment_when_no_charge" do
    user = users(:user4)
    login_user(user)
    get update_payment_charges_path
    assert_redirected_to pro_root_path
  end

  test "access_update_payment_when_charge_exist" do
    user = users(:user1)
    login_user(user)
    get update_payment_charges_path
    assert_redirected_to edit_charge_path(user.charge)
  end
end
