require File.dirname(__FILE__) + '/../test_helper'

class BcommentsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:bcomments)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_bcomment
    assert_difference('Bcomment.count') do
      post :create, :bcomment => { }
    end

    assert_redirected_to bcomment_path(assigns(:bcomment))
  end

  def test_should_show_bcomment
    get :show, :id => bcomments(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => bcomments(:one).id
    assert_response :success
  end

  def test_should_update_bcomment
    put :update, :id => bcomments(:one).id, :bcomment => { }
    assert_redirected_to bcomment_path(assigns(:bcomment))
  end

  def test_should_destroy_bcomment
    assert_difference('Bcomment.count', -1) do
      delete :destroy, :id => bcomments(:one).id
    end

    assert_redirected_to bcomments_path
  end
end
