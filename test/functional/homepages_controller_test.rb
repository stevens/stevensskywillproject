require File.dirname(__FILE__) + '/../test_helper'

class HomepagesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:homepages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_homepage
    assert_difference('Homepage.count') do
      post :create, :homepage => { }
    end

    assert_redirected_to homepage_path(assigns(:homepage))
  end

  def test_should_show_homepage
    get :show, :id => homepages(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => homepages(:one).id
    assert_response :success
  end

  def test_should_update_homepage
    put :update, :id => homepages(:one).id, :homepage => { }
    assert_redirected_to homepage_path(assigns(:homepage))
  end

  def test_should_destroy_homepage
    assert_difference('Homepage.count', -1) do
      delete :destroy, :id => homepages(:one).id
    end

    assert_redirected_to homepages_path
  end
end
