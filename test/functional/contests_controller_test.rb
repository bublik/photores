require 'test_helper'

class ContestsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:contests)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_contest
    assert_difference('Contest.count') do
      post :create, :contest => { }
    end

    assert_redirected_to contest_path(assigns(:contest))
  end

  def test_should_show_contest
    get :show, :id => contests(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => contests(:one).id
    assert_response :success
  end

  def test_should_update_contest
    put :update, :id => contests(:one).id, :contest => { }
    assert_redirected_to contest_path(assigns(:contest))
  end

  def test_should_destroy_contest
    assert_difference('Contest.count', -1) do
      delete :destroy, :id => contests(:one).id
    end

    assert_redirected_to contests_path
  end
end
