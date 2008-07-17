require File.dirname(__FILE__) + '/../test_helper'

class DataElementsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:data_elements)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_data_element
    assert_difference('DataElement.count') do
      post :create, :data_element => { }
    end

    assert_redirected_to data_element_path(assigns(:data_element))
  end

  def test_should_show_data_element
    get :show, :id => data_elements(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => data_elements(:one).id
    assert_response :success
  end

  def test_should_update_data_element
    put :update, :id => data_elements(:one).id, :data_element => { }
    assert_redirected_to data_element_path(assigns(:data_element))
  end

  def test_should_destroy_data_element
    assert_difference('DataElement.count', -1) do
      delete :destroy, :id => data_elements(:one).id
    end

    assert_redirected_to data_elements_path
  end
end
