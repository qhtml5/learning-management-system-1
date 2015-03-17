include ActionDispatch::TestProcess

FactoryGirl.define do

  factory :draft_course, :class => Course do
		sequence(:title) { |n| "F_TITLE#{n}" }
		status Course::DRAFT
		# school
		# teachers { [FactoryGirl.create(:teacher)] }

		factory :course do
			pitch "F_PITCH"
			description "F_DESCRIPTION"
			who_should_attend 'F Who Should Attend'
			content_and_goals 'F Content and Goals'
			logo_file_name { 'missing_original.png' }
			logo_content_type { 'image/png' }
			logo_file_size { 1024 }
			price 4500

			callback(:after_build, :before_create) do |course|
				course.save!
				lesson = FactoryGirl.create(:lesson, course: course)
				lessons_medias = FactoryGirl.create(:lesson_media, lesson: lesson, media: FactoryGirl.build(:media))
		  end

		  callback(:after_create) do |course|
				course.status = "published"
				course.save!
			end
		end
	end
end