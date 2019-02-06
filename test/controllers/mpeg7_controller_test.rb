require 'test_helper'

class Mpeg7ControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mpeg7_index_url
    assert_response :success
  end

end
