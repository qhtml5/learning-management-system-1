# encoding: utf-8

require 'spec_helper'

describe Users::RegistrationsController do
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	describe "POST create" do
		context "success" do
			let(:user_params) do
				{
					first_name: "John",
					email: "john@gmail.com",
					password: "abc123"
				}
			end

			it "should create and login user" do
				post :create, user: user_params
				@user = User.last
				@user.first_name.should == "John"
				@user.email.should == "john@gmail.com"
				@user.sign_in_count.should_not be_zero
			end

			context "on Edools" do
				it "should redirect to wizard first step" do
					post :create, user: user_params
				end
			end

			context "on School" do
				let(:school_admin) { create(:school_admin) }
				let(:school) { school_admin.school }

				before(:each) do
					School.current_id = school.id
					controller.stub current_school: school
					controller.request.stub subdomain: school.subdomain
				end

				it "should register on rdstation that user registered" do
					User.any_instance.should_receive(:register_on_rdstation).with(school.name.parameterize)
					post :create, user: user_params
				end

				it "should send notification to school team" do
					school.teachers = [create(:teacher)]
					school.save!
					Notification.should_receive(:create_list).with do |*args|
						notification = args.pop
						notification[:sender].email.should == "john@gmail.com"
						notification[:receivers].should == school.team
						notification[:code].should == Notification::USER_NEW_REGISTRATION
						notification[:notifiable].email.should == "john@gmail.com"
						true
					end
					post :create, user: user_params
				end

				it "should redirect to root" do
					post :create, user: user_params
					response.should redirect_to root_path(subdomain: school.subdomain)
				end


				it "should redirect to register checkout page if came from social page" do
					post :create, user: user_params, checkout_registration: "Criar conta"
					response.should redirect_to register_checkouts_path(subdomain: school.subdomain)
				end

				context "free purchase registration" do
					let(:course) { create(:course) }

					it "should redirect to content course page" do
						post :create, user: user_params, course: course
						response.should redirect_to content_course_path(course)
					end

					it "should atribute courses invited to user" do
						post :create, user: user_params, course: course
						user = User.find_by_email "john@gmail.com"
						user.courses_invited.should include course
					end

					it "should on rdstation that user bought the course" do
						User.any_instance.should_receive(:register_on_rdstation).once.with(school.name.parameterize)
						User.any_instance.should_receive(:register_on_rdstation).once.with("confirmado_#{course.slug}")
						post :create, user: user_params, course: course
					end

					it "should destroy invitation if present" do
						invitation = create(:invitation, course: course)
						expect {
							post :create, user: user_params, course: course, invitation: invitation
						}.to change(Invitation, :count).by(-1)
					end
				end

				context "restrict course registration" do
					let(:course) { create(:course) }

					it "should redirect to add to cart page" do
						post :create, user: user_params, course: course, restrict: true
						response.should redirect_to add_to_cart_course_path(course)
					end
				end
			end
		end

		context "failure" do
			let(:user_params) do
				{
					first_name: "John",
					email: "a",
					password: "abc123"
				}
			end	

			context "in checkout" do
				it "should assign @user" do
					post :create, user: user_params, checkout_registration: "Criar conta"
					assigns(:user).should be_an_instance_of(User)
				end

				it "should render template checkout social" do
					post :create, user: user_params, checkout_registration: "Criar conta"
					response.should render_template "checkouts/social"
				end
			end

			context "not in checkout" do
				it "should render new registrations template" do
					post :create, user: user_params
					response.should render_template "devise/registrations/new"
				end
			end
		end
	end

	describe "PUT update" do
		let(:user) { create(:user) }
		before(:each) { sign_in(user) } 

		let(:user_params) do
			{
				first_name: "Johnny",
				email: "johnny@email.com"
			}
		end

		context "purchasing" do
			let(:school) { create(:school) }
			before(:each) do
				School.current_id = school.id
				controller.stub current_school: school
				controller.request.stub subdomain: school.subdomain
			end
			let(:cart_item) { create(:cart_item) }
			let(:cart) { cart_item.cart }
			before(:each) do
				controller.stub current_cart: cart
				MyMoip::TransparentRequest.any_instance.stub api_call: true
			end

			context "success" do
				it "should update user attributes" do
					put :update, user: user_params, commit: "Prosseguir"
					user.reload
					user.first_name.should == "Johnny"
					user.email.should == "johnny@email.com"
				end

				context "Cart total is greater than R$ 0,00" do
					context "Checkout success" do
						before(:each) do
							MyMoip::TransparentRequest.any_instance.stub token: "abc123"
						end

						it "should set flash notice" do
							put :update, user: user_params, commit: "Prosseguir"
							flash[:notice].should == "Cadastro completo com sucesso, efetue o pagamento"
						end

						it "should redirect to payment checkout page" do
							put :update, user: user_params, commit: "Prosseguir"
							response.should redirect_to payment_checkouts_path(subdomain: school.subdomain)
						end
					end

					context "Checkout failure" do
						before(:each) do
							MyMoip::TransparentRequest.any_instance.stub token: nil
						end

						it "should redirect to exception page" do
							put :update, user: user_params, commit: "Prosseguir"
							response.should redirect_to exception_checkouts_path(subdomain: school.subdomain)
						end

						it "should send support email" do
							put :update, user: user_params, commit: "Prosseguir"
							ActionMailer::Base.deliveries.last.subject.should == "[Edools ERROR] Falha no Checkout"
						end
					end
				end

				context "Cart total is R$ 0,00" do
					before(:each) do
						coupon = create(:coupon, discount: 100)
						cart.cart_items.first.update_attribute :coupon, coupon
					end

					it "should create one completed purchase" do
						expect { 
							put :update, user: user_params, commit: "Prosseguir"
						}.to change(user.purchases.payment_confirmed, :count).by(1)
					end

					it "should redirect to finish coupon page" do
						put :update, user: user_params, commit: "Prosseguir"
						response.should redirect_to finish_coupon_checkouts_path(subdomain: school.subdomain)
					end
				end

			end

			context "failure" do
				before(:each) { user_params[:first_name] = "" }

				it "should render checkout register template" do
					put :update, user: user_params, commit: "Prosseguir"
					response.should render_template "checkouts/register"
				end
			end
		end

		context "editing" do
			context "success" do

				it "should update user attributes" do
					put :update, user: user_params, commit: "Salvar"
					user.reload
					user.first_name.should == "Johnny"
					user.email.should == "johnny@email.com"
				end

				it "should set flash notice" do
					put :update, user: user_params, commit: "Salvar"
					flash[:notice].should == I18n.t("messages.user.profile.update.success")
				end

				it "should redirect to edit profile page" do
					put :update, user: user_params, commit: "Salvar"
					response.should redirect_to edit_profile_user_path(subdomain: "www")
				end
			end

			context "failure" do
				before(:each) { user_params[:first_name] = "" }

				it "should render edit profile template" do
					put :update, user: user_params, commit: "Salvar"
					response.should render_template "users/edit_profile"
				end
			end
		end
	end

	describe ".checkout" do
		let(:school) { create(:school) }
		before(:each) { School.current_id = school.id }
		let(:course) { create(:course) }
		let(:cart_item) { create(:cart_item, course: course) }
		let(:cart) { cart_item.cart }
		let(:user) { create(:user) }

		let(:user_params) do
			{
				first_name: "Johnny",
				email: "johnny@email.com"
			}
		end

		before(:each) do
			sign_in user
			controller.stub current_cart: cart
			MyMoip::TransparentRequest.any_instance.stub api_call: true
			controller.stub current_school: school
		end


		it "should build payer" do
			MyMoip::Payer.should_receive(:new).exactly(1).times
			put :update, user: user_params, commit: "Prosseguir"
		end

		it "should build valid instruction when school is in middle or high plan" do
			controller.stub_chain(:current_school, :commissioned_plan?).and_return(false)
			MyMoip::Instruction.should_receive(:new).with do |*args|
				instruction = args.pop
				instruction[:values].should == [45.0]
				instruction[:id].should be_an_instance_of(String)
				instruction[:payer].should be_valid
				# instruction[:installments].should == [{ min: 1, max: 12, forward_taxes: true, fee: 2.99 }]
				instruction[:payment_receiver_login].should == school.moip_login
				instruction[:fee_payer_login].should == school.moip_login
				true
			end
			put :update, user: user_params, commit: "Prosseguir"
		end

		it "should update token and identificator of cart" do
			MyMoip::TransparentRequest.any_instance.stub(token: "abcABC123")
			put :update, user: user_params, commit: "Prosseguir"
			cart.reload
			cart.token.should_not be_nil
			cart.identificator.should_not be_nil
		end

		it "should redirect to exception page when error occur" do
			MyMoip::TransparentRequest.any_instance.stub(:api_call).and_raise
			put :update, user: user_params, commit: "Prosseguir"
			response.should redirect_to exception_checkouts_path(subdomain: school.subdomain)
		end

		it "should send support email when error occur" do
			MyMoip::TransparentRequest.any_instance.stub(:api_call).and_raise
			put :update, user: user_params, commit: "Prosseguir"
			ActionMailer::Base.deliveries.last.subject.should == "[Edools ERROR] Exceção no Checkout"
		end
	end

end