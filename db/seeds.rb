require "net/http"
require "json"
require "uri"

Product.delete_all
Category.delete_all

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

# Fetch API to populate data to database
url = "http://makeup-api.herokuapp.com/api/v1/products.json"
uri = URI(url)
response = Net::HTTP.get(uri)
data = JSON.parse(response)

data.each do |product_data|
  category = Category.find_or_create_by(name: product_data["product_type"])

  if category && category.valid?
    image_link = product_data["image_link"]

    if valid_image_link?(image_link) && !description_has_html_tag?(product_data["description"])

      product = category.products.create(
        name:        product_data["name"],
        price:       Faker::Commerce.price,
        image_link:,
        description: product_data["description"]
      )

    else
      puts "Invalid image link: #{image_link}"
    end
  else
    puts "Invalid category #{product_data['product_type']}"
  end
end

puts "Created #{Category.count} categories"
puts "Created #{Brand.count} brands"
puts "Created #{Product.count} products"
puts "Created #{Tag.count} tags"
puts "Created #{ProductTag.count} product tags"
