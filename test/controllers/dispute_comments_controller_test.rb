require "test_helper"

class DisputeCommentsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get dispute_comments_create_url
    assert_response :success
  end
end
