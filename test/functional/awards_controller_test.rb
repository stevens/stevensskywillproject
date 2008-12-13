require File.dirname(__FILE__) + '/../test_helper'

class AwardsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:awards)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_award
    assert_difference('Award.count') do
      post :create, :award => { }
    end

    assert_redirected_to award_path(assigns(:award))
  end

  def test_should_show_award
    get :show, :id => awards(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => awards(:one).id
    assert_response :success
  end

  def test_should_update_award
    put :update, :id => awards(:one).id, :award => { }
    assert_redirected_to award_path(assigns(:award))
  end

  def test_should_destroy_award
    assert_difference('Award.count', -1) do
      delete :destroy, :id => awards(:one).id
    end

    assert_redirected_to awards_path
  end
end
