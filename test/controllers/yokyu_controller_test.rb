require 'test_helper'

class YokyuControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get yokyu_index_url
    assert_response :success
  end

  test "should get learn" do
    get yokyu_learn_url
    assert_response :success
  end

  test "should get answer" do
    get yokyu_answer_url
    assert_response :success
  end

end
