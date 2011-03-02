require File.dirname(__FILE__) + '/../../test_helper'

class Admin::CameraBrandsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:camera_brands)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_camera_brand
    assert_difference('CameraBrand.count') do
      post :create, :camera_brand => { }
    end

    assert_redirected_to camera_brand_path(assigns(:camera_brand))
  end

  def test_should_show_camera_brand
    get :show, :id => camera_brands(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => camera_brands(:one).id
    assert_response :success
  end

  def test_should_update_camera_brand
    put :update, :id => camera_brands(:one).id, :camera_brand => { }
    assert_redirected_to camera_brand_path(assigns(:camera_brand))
  end

  def test_should_destroy_camera_brand
    assert_difference('CameraBrand.count', -1) do
      delete :destroy, :id => camera_brands(:one).id
    end

    assert_redirected_to camera_brands_path
  end
end
