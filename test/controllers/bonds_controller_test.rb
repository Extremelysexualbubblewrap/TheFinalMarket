require "test_helper"

class BondsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get bonds_new_url
    assert_response :success
  end

  test "should get create" do
    get bonds_create_url
    assert_response :success
  end
end
