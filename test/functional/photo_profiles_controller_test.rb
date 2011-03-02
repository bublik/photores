require 'test_helper'

class PhotoProfilesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:photo_profiles)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_photo_profile
    assert_difference('PhotoProfile.count') do
      post :create, :photo_profile => { }
    end

    assert_redirected_to photo_profile_path(assigns(:photo_profile))
  end

  def test_should_show_photo_profile
    get :show, :id => photo_profiles(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => photo_profiles(:one).id
    assert_response :success
  end

  def test_should_update_photo_profile
    put :update, :id => photo_profiles(:one).id, :photo_profile => { }
    assert_redirected_to photo_profile_path(assigns(:photo_profile))
  end

  def test_should_destroy_photo_profile
    assert_difference('PhotoProfile.count', -1) do
      delete :destroy, :id => photo_profiles(:one).id
    end

    assert_redirected_to photo_profiles_path
  end
end
