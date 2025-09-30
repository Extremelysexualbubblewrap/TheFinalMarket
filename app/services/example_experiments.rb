class ExampleExperiments
  def self.setup
    # Product page layout test
    AbTestingService.register_experiment(
      name: 'product_page_layout',
      variants: ['standard', 'immersive', 'minimal'],
      description: 'Testing different product page layouts to improve conversion rate',
      traffic_percentage: 100
    )

    # Price display test
    AbTestingService.register_experiment(
      name: 'product_price_display',
      variants: ['standard', 'with_savings', 'with_comparison'],
      description: 'Testing different price display formats to optimize purchase decisions',
      traffic_percentage: 100
    )

    # Product grid layout test
    AbTestingService.register_experiment(
      name: 'product_grid_layout',
      variants: ['standard', 'compact', 'gallery'],
      description: 'Testing different product grid layouts to improve engagement',
      traffic_percentage: 100
    )

    # Default sorting test
    AbTestingService.register_experiment(
      name: 'product_default_sort',
      variants: ['newest', 'popular', 'price_asc'],
      description: 'Testing different default sorting options to improve user experience',
      traffic_percentage: 100
    )

    # Add to cart button test
    AbTestingService.register_experiment(
      name: 'add_to_cart_button',
      variants: [
        'Add to Cart',
        'Buy Now',
        'Add to Basket'
      ],
      description: 'Testing different CTA text to improve cart addition rate',
      traffic_percentage: 100
    )

    # Search results per page test
    AbTestingService.register_experiment(
      name: 'search_results_per_page',
      variants: ['12', '24', '36'],
      description: 'Testing different number of products per page to optimize user engagement',
      traffic_percentage: 100
    )

    # Mobile navigation test
    AbTestingService.register_experiment(
      name: 'mobile_navigation',
      variants: ['bottom_nav', 'hamburger_menu', 'tabbed_nav'],
      description: 'Testing different mobile navigation patterns to improve mobile usability',
      traffic_percentage: 100
    )
  end
end