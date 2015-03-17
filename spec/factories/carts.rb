FactoryGirl.define do
  factory :cart do
  	callback(:after_build, :before_create) do |cart|
			cart.cart_items { [FactoryGirl.build(:cart_item_base, cart: cart)] }
		end
  end
end
