require 'test_helper'

class PrivMessagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:priv_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create priv_message" do
    assert_difference('PrivMessage.count') do
      post :create, :priv_message => { }
    end

    assert_redirected_to priv_message_path(assigns(:priv_message))
  end

  test "should show priv_message" do
    get :show, :id => priv_messages(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => priv_messages(:one).to_param
    assert_response :success
  end

  test "should update priv_message" do
    put :update, :id => priv_messages(:one).to_param, :priv_message => { }
    assert_redirected_to priv_message_path(assigns(:priv_message))
  end

  test "should destroy priv_message" do
    assert_difference('PrivMessage.count', -1) do
      delete :destroy, :id => priv_messages(:one).to_param
    end

    assert_redirected_to priv_messages_path
  end
end
