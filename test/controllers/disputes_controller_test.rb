require "test_helper"

class DisputesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get disputes_index_url
    assert_response :success
  end

  test "should get show" do
    get disputes_show_url
    assert_response :success
  end

  test "should get new" do
    get disputes_new_url
    assert_response :success
  end

  test "should get create" do
    get disputes_create_url
    assert_response :success
  end
end
