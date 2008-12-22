require File.dirname(__FILE__) + '/../test_helper'

class MatchActorsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:match_actors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_match_actor
    assert_difference('MatchActor.count') do
      post :create, :match_actor => { }
    end

    assert_redirected_to match_actor_path(assigns(:match_actor))
  end

  def test_should_show_match_actor
    get :show, :id => match_actors(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => match_actors(:one).id
    assert_response :success
  end

  def test_should_update_match_actor
    put :update, :id => match_actors(:one).id, :match_actor => { }
    assert_redirected_to match_actor_path(assigns(:match_actor))
  end

  def test_should_destroy_match_actor
    assert_difference('MatchActor.count', -1) do
      delete :destroy, :id => match_actors(:one).id
    end

    assert_redirected_to match_actors_path
  end
end
