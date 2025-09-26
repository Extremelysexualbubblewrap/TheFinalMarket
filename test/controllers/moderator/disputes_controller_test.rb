require "test_helper"

class Moderator::DisputesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get moderator_disputes_index_url
    assert_response :success
  end

  test "should get show" do
    get moderator_disputes_show_url
    assert_response :success
  end

  test "should get update" do
    get moderator_disputes_update_url
    assert_response :success
  end

  test "should get resolve" do
    get moderator_disputes_resolve_url
    assert_response :success
  end

  test "should get dismiss" do
    get moderator_disputes_dismiss_url
    assert_response :success
  end
end
