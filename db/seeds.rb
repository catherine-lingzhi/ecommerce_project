require "net/http"
require "json"
require "uri"
Product.delete_all
Category.delete_all
ProductStatus.delete_all

# Create ProductStatus Table
statuses = ["New", "On Sale", "Recently Updated"]

statuses.each do |status_name|
  ProductStatus.find_or_create_by(name: status_name)
end

# Helper function to validate image link
def valid_image_link?(image_link)
  uri = URI(image_link)
  response = Net::HTTP.get_response(uri)
  response.code.to_i == 200
rescue Errno::ECONNREFUSED, SocketError
  puts "Error: Failed to connect to the image link: #{image_link}"
  false
end

# Helper function to check if description contains HTML tag
def description_has_html_tag?(description)
  !!(description =~ %r{</?[a-z][\s\S]*>})
end

# Fetch API to populate data to the database
url = "http://makeup-api.herokuapp.com/api/v1/products.json"
uri = URI(url)
response = Net::HTTP.get(uri)
data = JSON.parse(response)

# Fetch the default status "New"
new_status = ProductStatus.find_by(name: "New")

unless new_status
  puts "Creating 'New' status..."
  new_status = ProductStatus.create(name: "New")
end

# Counter to limit the number of products
products_created = 0
desired_product_limit = 200

data.each do |product_data|
  break if products_created >= desired_product_limit

  category = Category.find_or_create_by(name: product_data["product_type"])

  if category && category.valid?
    image_link = product_data["image_link"]

    if valid_image_link?(image_link) && !description_has_html_tag?(product_data["description"])
      # db/seeds.rb
      product = category.products.create(
        name:           product_data["name"],
        price:          product_data["price"],
        image_link:,
        description:    product_data["description"],
        product_status: ProductStatus.find_by(name: statuses.sample) # Randomly assign a product status
      )

      products_created += 1
    else
      puts "Invalid image link: #{image_link}"
    end
  else
    puts "Invalid category #{product_data['product_type']}"
  end
end

puts "Created #{Category.count} categories"
puts "Created #{Product.count} products"
puts "Created #{ProductStatus.count} product Status"
