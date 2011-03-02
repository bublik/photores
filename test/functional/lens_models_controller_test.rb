require 'test_helper'

class LensModelsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:lens_models)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_lens_model
    assert_difference('LensModel.count') do
      post :create, :lens_model => { }
    end

    assert_redirected_to lens_model_path(assigns(:lens_model))
  end

  def test_should_show_lens_model
    get :show, :id => lens_models(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => lens_models(:one).id
    assert_response :success
  end

  def test_should_update_lens_model
    put :update, :id => lens_models(:one).id, :lens_model => { }
    assert_redirected_to lens_model_path(assigns(:lens_model))
  end

  def test_should_destroy_lens_model
    assert_difference('LensModel.count', -1) do
      delete :destroy, :id => lens_models(:one).id
    end

    assert_redirected_to lens_models_path
  end
end
