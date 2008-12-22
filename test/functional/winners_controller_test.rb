require File.dirname(__FILE__) + '/../test_helper'

class WinnersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:winners)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_winner
    assert_difference('Winner.count') do
      post :create, :winner => { }
    end

    assert_redirected_to winner_path(assigns(:winner))
  end

  def test_should_show_winner
    get :show, :id => winners(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => winners(:one).id
    assert_response :success
  end

  def test_should_update_winner
    put :update, :id => winners(:one).id, :winner => { }
    assert_redirected_to winner_path(assigns(:winner))
  end

  def test_should_destroy_winner
    assert_difference('Winner.count', -1) do
      delete :destroy, :id => winners(:one).id
    end

    assert_redirected_to winners_path
  end
end
