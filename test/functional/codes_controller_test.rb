require File.dirname(__FILE__) + '/../test_helper'

class CodesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:codes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_code
    assert_difference('Code.count') do
      post :create, :code => { }
    end

    assert_redirected_to code_path(assigns(:code))
  end

  def test_should_show_code
    get :show, :id => codes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => codes(:one).id
    assert_response :success
  end

  def test_should_update_code
    put :update, :id => codes(:one).id, :code => { }
    assert_redirected_to code_path(assigns(:code))
  end

  def test_should_destroy_code
    assert_difference('Code.count', -1) do
      delete :destroy, :id => codes(:one).id
    end

    assert_redirected_to codes_path
  end
end
