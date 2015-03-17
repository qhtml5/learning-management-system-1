#coding: utf-8

require 'spec_helper'

feature 'Carrinho' do
	background do
		@school = create(:school)
		School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain(@course.school.subdomain)
	end

	scenario "Aluno adiciona curso ao carrinho" do
		visit add_to_cart_course_path(@course)
		@cart = Cart.last

		current_path.should == cart_checkouts_path
		page.should have_content @course.title
		page.should have_content @course.pitch
		page.should have_content @course.price.em_real
		# page.should have_content "Carrinho (#{@cart.courses.length})"
	end

	scenario "Aluno remove curso do carrinho" do
		visit add_to_cart_course_path(@course)
		@cart = Cart.last
		
		click_on "remove-course-#{@course.slug}"
		page.should_not have_content @course.title
		within("#header") do
			page.should_not have_content "Carrinho (#{@cart.courses.length})"
		end
	end

	scenario "Aluno tenta adicionar curso em rascunho ao carrinho" do
		@draft_course = FactoryGirl.create(:draft_course, school: @course.school)
		visit add_to_cart_course_path(@draft_course)

		@cart = Cart.last
		page.should have_content "Este curso não pode ser comprado"
		current_path.should == root_path
	end

	scenario "Aluno tenta adicionar um curso que já está no carrinho" do
		visit add_to_cart_course_path(@course)
		visit add_to_cart_course_path(@course)

		@cart = Cart.last

		@cart.courses.should == [@course]
		current_path.should == cart_checkouts_path
	end	

	scenario "Aluno aplica cupom" do
		@coupon = create(:coupon, course: @course)
		visit add_to_cart_course_path(@course)


		fill_in "cart-coupon-course-#{@course.id}", with: @coupon.name
		click_on "refresh-coupon-#{@course.id}"

		@cart_item = CartItem.last

		page.should have_content "Cupom adicionado com sucesso"
		@cart_item.coupon.should == @coupon
		page.should_not have_content @course.price.em_real
		page.should have_content @cart_item.price_with_discount.em_real
  end

	scenario "Aluno tenta aplicar cupom inválido" do
		visit add_to_cart_course_path(@course)

		fill_in "cart-coupon-course-#{@course.id}", with: "Cupom inválido"
		click_on "refresh-coupon-#{@course.id}"

		page.should have_content "Cupom inválido"
		current_path.should == cart_checkouts_path
  end

  scenario "Aluno remove cupom" do
		@coupon = create(:coupon, course: @course)
		visit add_to_cart_course_path(@course)
		fill_in "cart-coupon-course-#{@course.id}", with: @coupon.name
		click_on "refresh-coupon-#{@course.id}"

		click_on "remove-coupon-#{@course.id}"
		page.should have_content "Cupom removido com sucesso"
  end

end
