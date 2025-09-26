# Create main categories
electronics = Category.create!(
  name: "Electronics",
  description: "Electronic devices and accessories",
  position: 1
)

fashion = Category.create!(
  name: "Fashion",
  description: "Clothing, shoes, and accessories",
  position: 2
)

home = Category.create!(
  name: "Home & Garden",
  description: "Everything for your home and garden",
  position: 3
)

# Create subcategories for Electronics
Category.create!([
  {
    name: "Smartphones",
    description: "Mobile phones and accessories",
    parent: electronics,
    position: 1
  },
  {
    name: "Laptops",
    description: "Notebooks and accessories",
    parent: electronics,
    position: 2
  },
  {
    name: "Gaming",
    description: "Gaming consoles and video games",
    parent: electronics,
    position: 3
  }
])

# Create subcategories for Fashion
Category.create!([
  {
    name: "Men's Clothing",
    description: "Clothes for men",
    parent: fashion,
    position: 1
  },
  {
    name: "Women's Clothing",
    description: "Clothes for women",
    parent: fashion,
    position: 2
  },
  {
    name: "Accessories",
    description: "Bags, jewelry, and other accessories",
    parent: fashion,
    position: 3
  }
])

# Create subcategories for Home & Garden
Category.create!([
  {
    name: "Furniture",
    description: "Indoor and outdoor furniture",
    parent: home,
    position: 1
  },
  {
    name: "Kitchen",
    description: "Kitchen appliances and accessories",
    parent: home,
    position: 2
  },
  {
    name: "Garden",
    description: "Garden tools and outdoor living",
    parent: home,
    position: 3
  }
])