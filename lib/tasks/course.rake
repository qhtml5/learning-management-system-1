namespace :course do
	task :buy, [:email, :course_ids] => [:environment] do |t, args|
		@user = User.find_by_email args[:email]
		@courses = Course.find args[:course_ids].split(";")
		Purchase.create!(:user => @user, :courses => @courses, :payment_status => "Concluido", :identificator => "#{Time.now.strftime("%Y%m%d%H%M%s")}#{rand(100)}")
	end

	task :buy_undo, [:email, :course_ids] => [:environment] do |t, args|
		@user = User.find_by_email args[:email]
		@courses = Course.find args[:course_ids].split(";")
		@user.purchases.each do |purchase|
			if purchase.courses == @courses
				purchase.destroy
			else
				@courses.each { |course| purchase.courses.delete(course) }
			end
		end
		@user.save!
	end

	task :associate_user, [:course_slug, :email] => [:environment] do |t, args|
		@user = User.find_by_email args[:email]
		@course = Course.find_by_slug args[:course_slug]
		School.current_id = @course.school.id
		@cart_item = CartItem.create course: @course, cart: Cart.create
		Purchase.create! user: @user, cart_items: [@cart_item], payment_status: "Concluido", :identificator => "#{Time.now.strftime("%Y%m%d%H%M%s")}#{rand(100)}"
	end

	task :associate_media, [:course_slug, :media_title, :wistia_id] => [:environment] do |t, args|
		@course = Course.find_by_slug args[:course_slug]
		@media = @course.medias.find_by_title args[:media_title]
		@media.update_attribute :wistia_hashed_id, args[:wistia_id]
	end
end