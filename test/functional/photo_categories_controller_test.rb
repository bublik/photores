require 'test_helper'

class PhotoCategoriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:photo_categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_photo_category
    assert_difference('PhotoCategory.count') do
      post :create, :photo_category => { }
    end

    assert_redirected_to photo_category_path(assigns(:photo_category))
  end

  def test_should_show_photo_category
    get :show, :id => photo_categories(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => photo_categories(:one).id
    assert_response :success
  end

  def test_should_update_photo_category
    put :update, :id => photo_categories(:one).id, :photo_category => { }
    assert_redirected_to photo_category_path(assigns(:photo_category))
  end

  def test_should_destroy_photo_category
    assert_difference('PhotoCategory.count', -1) do
      delete :destroy, :id => photo_categories(:one).id
    end

    assert_redirected_to photo_categories_path
  end
end
