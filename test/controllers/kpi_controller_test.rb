require 'test_helper'

class KpiControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get kpi_index_url
    assert_response :success
  end

end
