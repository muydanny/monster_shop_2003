require 'rails_helper'

describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :price }
    it { should validate_presence_of :inventory }
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should have_many :reviews}
    it {should have_many :item_orders}
    it {should have_many(:orders).through(:item_orders)}
  end

  describe "class methods" do
    before(:each) do
      login_user
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @pull_toy = @brian.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
      @dog_bone = @brian.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:true, inventory: 21)
      @bone = @brian.items.create(name: "A Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:true, inventory: 21)
      @toy = @brian.items.create(name: "A Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
      @order = Order.create!(name: "name", address: "address", city: "city", state: "state", zip: 23455, user_id: @user.id)
      @order2 = Order.create!(name: "name", address: "address", city: "city", state: "state", zip: 23455, user_id: @user.id)
      ItemOrder.create!(order_id: @order.id, price: 1.0, item_id: @dog_bone.id, quantity: 5)
      ItemOrder.create!(order_id: @order.id, price: 1.0, item_id: @pull_toy.id, quantity: 1)
      ItemOrder.create!(order_id: @order.id, price: 1.0, item_id: @tire.id, quantity: 4)
      ItemOrder.create!(order_id: @order.id, price: 1.0, item_id: @toy.id, quantity: 3)
      ItemOrder.create!(order_id: @order.id, price: 1.0, item_id: @bone.id, quantity: 2)
      ItemOrder.create!(order_id: @order2.id, price: 1.0, item_id: @dog_bone.id, quantity: 3)
      ItemOrder.create!(order_id: @order2.id, price: 1.0, item_id: @pull_toy.id, quantity: 4)
    end

    it ".top_5" do
      expect(Item.top_5).to eq({ @dog_bone.name => 8, @pull_toy.name => 5, @tire.name => 4, @toy.name => 3, @bone.name => 2})

      @dog_bone.update(active?: false)

      expect(Item.top_5).to eq({ @pull_toy.name => 5, @tire.name => 4, @toy.name => 3, @bone.name => 2})
    end

    it ".worst_5" do
      expect(Item.worst_5).to eq({ @bone.name => 2, @toy.name => 3, @tire.name => 4, @pull_toy.name => 5, @dog_bone.name => 8 })

      @dog_bone.update(active?: false)

      expect(Item.worst_5).to eq({ @bone.name => 2, @toy.name => 3, @tire.name => 4, @pull_toy.name => 5 })      
    end
  end

  describe "instance methods" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)

      @review_1 = @chain.reviews.create(title: "Great place!", content: "They have great bike stuff and I'd recommend them to anyone.", rating: 5)
      @review_2 = @chain.reviews.create(title: "Cool shop!", content: "They have cool bike stuff and I'd recommend them to anyone.", rating: 4)
      @review_3 = @chain.reviews.create(title: "Meh place", content: "They have meh bike stuff and I probably won't come back", rating: 1)
      @review_4 = @chain.reviews.create(title: "Not too impressed", content: "v basic bike shop", rating: 2)
      @review_5 = @chain.reviews.create(title: "Okay place :/", content: "Brian's cool and all but just an okay selection of items", rating: 3)
    end

    it "#calculate average review" do
      expect(@chain.average_review).to eq(3.0)
    end

    it "#sorts reviews" do
      top_three = @chain.sorted_reviews(3,:desc)
      bottom_three = @chain.sorted_reviews(3,:asc)

      expect(top_three).to eq([@review_1,@review_2,@review_5])
      expect(bottom_three).to eq([@review_3,@review_4,@review_5])
    end

    it '#no orders' do
      login_user
      expect(@chain.no_orders?).to eq(true)
      order = Order.create(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id)
      order.item_orders.create(item: @chain, price: @chain.price, quantity: 2)
      expect(@chain.no_orders?).to eq(false)
    end

    it '#update_inventory' do
      @chain.update_inventory(2)
      expect(@chain.inventory).to eq(3)
    end
  end
end
