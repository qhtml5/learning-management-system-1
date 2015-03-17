FactoryGirl.define do
  factory :cart_item_base, class: CartItem do
		course

		factory :cart_item do
			cart
		end
  end
end
