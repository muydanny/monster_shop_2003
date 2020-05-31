require 'rails_helper'

RSpec.describe 'Cart show' do
  describe 'When I have added items to my cart' do
    before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"
      @items_in_cart = [@paper,@tire,@pencil]
    end

    it 'Theres a link to checkout' do
      visit "/cart"

      expect(page).to have_link("Checkout")

      click_on "Checkout"

      expect(current_path).to eq("/orders/new")
    end
  end

  describe 'When I havent added items to my cart' do
    it 'There is not a link to checkout' do
      visit "/cart"

      expect(page).to_not have_link("Checkout")
    end
  end
  
  describe "When I have items in my cart" do 
     before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 2)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"
      @items_in_cart = [@paper,@tire,@pencil]
    end

    it "I see a button or link to increment the count of items I want to purchase" do 
      visit "/cart"
      
      expect(page).to have_link("Checkout")
      
      within(".cart-#{@tire.id}") do
        click_link "+"
      end

      expect(page).to have_content("You have changed your cart quantity.")
      expect(page).to have_content("2")
    end

    it "cannot add more to the cart than there is inventory for" do 
      visit "/cart"

      expect(page).to have_link("Checkout")
      expect(page).to have_link("Empty Cart")
 
      within(".cart-#{@tire.id}") do
        click_link "+"
      end

      expect(page).to have_content("You have changed your cart quantity.")
      expect(page).to have_content("2")

      within(".cart-#{@tire.id}") do
        click_link "+"
      end
      
      expect(page).to have_content("Not enough in inventory")
      expect(page).to have_content("2")

    end

    it "Decreasing Item Quantity from Cart and hit 0 item removed from cart" do
      visit "/cart"

      expect(page).to have_link("Checkout")
      expect(page).to have_link("Empty Cart")

      within(".cart-#{@tire.id}") do
        click_link "-"
      end

      within(".cart-#{@tire.id}") do
        click_link "-"
      end
      
      expect(page).to have_content("You have changed your cart quantity.")
      expect(page).to have_content(@paper.name)
      expect(page).to have_content(@pencil.name)
      expect(page).to_not have_content(@tire.name)
    end

    it "Visitors must register or log in to check out" do 
      visit "/cart"

      expect(page).to have_link("Login")
      expect(page).to have_link("Register")
      expect(page).to have_link("Empty Cart")
      expect(page).to have_link("Checkout")
      expect(page).to have_content("Please, log in or register to complete order")

      click_link("Empty Cart")

      expect(page).to_not have_link("Empty Cart")
      expect(page).to_not have_link("Checkout")
      expect(page).to_not have_content("Please, log in or register to complete order")
    end
  end
end



# User Story 25, Visitors must register or log in to check out

# As a visitor
# When I have items in my cart
# And I visit my cart
# I see information telling me I must register or log in to 
# finish the checkout process
# The word "register" is a link to the registration page
# The words "log in" is a link to the login page