require "test_helper"

class PaginasControllerTest < ActionDispatch::IntegrationTest
  test "cómo se juega es pública" do
    get como_se_juega_path
    assert_response :success
  end
end
