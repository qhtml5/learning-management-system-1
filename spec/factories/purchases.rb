FactoryGirl.define do
  factory :purchase do
		payment_status Purchase::INITIATED
		identificator { "#{Time.now.strftime("%Y%m%d%H%M%s")}#{rand(100)}#{rand(100)}" }
		user
		token "E2S05173C026S0U3X1X783E7U2D3087080Z0W070E0I0I0R359A84359Q1A9"

		callback(:after_build, :before_create) do |purchase|
  		purchase.cart_items = [ FactoryGirl.create(:cart_item_base, purchase: purchase) ] unless purchase.cart_items.any?
  	end

		factory :purchase_pending do
			payment_status Purchase::ANALYSING
		end

		factory :purchase_confirmed do
			payment_status Purchase::CONFIRMED
		end

		factory :purchase_with_credit_card do
			payment_status Purchase::CONFIRMED
			payment_type "CartaoCredito"
			amount_paid 100
		end
  end
end