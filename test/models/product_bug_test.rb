require "test_helper"

class ProductBugTest < ActiveSupport::TestCase
  test "should return the maximum price of all variants" do
    user = User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password', brand_name: 'Test Brand')
    product = Product.create!(name: "Test Product", description: "Test Description", price: 10.0, user: user)
    product.variants.create!(price: 20.0, stock_quantity: 1, name: 'Variant 1')
    product.variants.create!(price: 30.0, stock_quantity: 1, name: 'Variant 2')

    assert_equal 30.0, product.max_price
  end
end