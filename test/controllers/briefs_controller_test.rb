require 'test_helper'

class BriefsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get briefs_index_url
    assert_response :success
  end

end
