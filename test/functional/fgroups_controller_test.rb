require 'test_helper'

class FgroupsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:fgroups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_fgroup
    assert_difference('Fgroup.count') do
      post :create, :fgroup => { }
    end

    assert_redirected_to fgroup_path(assigns(:fgroup))
  end

  def test_should_show_fgroup
    get :show, :id => fgroups(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => fgroups(:one).id
    assert_response :success
  end

  def test_should_update_fgroup
    put :update, :id => fgroups(:one).id, :fgroup => { }
    assert_redirected_to fgroup_path(assigns(:fgroup))
  end

  def test_should_destroy_fgroup
    assert_difference('Fgroup.count', -1) do
      delete :destroy, :id => fgroups(:one).id
    end

    assert_redirected_to fgroups_path
  end
end
