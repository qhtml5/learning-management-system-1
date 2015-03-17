class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    end

    if user.school_admin?
      can [:dashboard_create], Course

      can :create, School

      can [:wizard_basic_info, :wizard_choose_plans, 
        :update, :finances, :edit_basic_info, :funnel, :crm, 
        :email_marketing, :cart_recovery, :social_media, :course_evaluations, 
        :certificate, :show_certificate, :students, :team, :library, :configurations,
        :integrations, :conversions, :coupons], School do |school|
          user.school == school
      end

      can [:index, :update], LayoutConfiguration

      can [:index, :show], :dashboard_user
    end

    if user.school_admin? || user.teacher?
      can [:dashboard_index, :dashboard_course_categories, :dashboard_sort_course_categories], Course

      can [:dashboard_show, :dashboard_update,
          :dashboard_edit_basic_info, :dashboard_edit_detailed_info, 
          :dashboard_edit_image, :dashboard_edit_promo_video, 
          :dashboard_edit_price_and_coupon, :dashboard_edit_privacy,
          :dashboard_edit_teachers, :dashboard_update_promo_video, 
          :dashboard_medias, :dashboard_edit_links_downloads,
          :dashboard_publish, :dashboard_unpublish, :dashboard_students,
          :dashboard_edit_available_time, :dashboard_edit_certificate, :dashboard_edit_instructor], Course do |course|
            user.courses.include? course
      end      

      can [:dashboard_medias_rename, :dashboard_medias_sort], Course do |course|
        user.courses.include? course
      end

      can [:dashboard_lessons_index, :dashboard_lessons_sort, :dashboard_lessons_rename], Course do |course|
            user.courses.include? course
      end

      can [:submit_message, :submit_answer, :destroy_message], Course do |course|
        user.courses.include? course
      end

      can [:update, :destroy], Coupon do |coupon|
        user.courses.include? coupon.course
      end

      can [:content, :show_media, :ended], Course do |course|
        user.courses.include? course
      end

      can :create, Coupon

      can :manage, Lesson do |lesson|
        if user.school
          user.school.lessons.include? lesson
        else
          user.lessons.include? lesson
        end
      end

      can :manage, Media do |media|
        if user.school
          user.school.medias.include? media
        else
          user.medias.include? media
        end
      end
    end

    if user.new_record? || user.persisted?    
      can :index, :pages
      can :home, User
      can [:add_to_cart, :remove_from_cart, :show, :index, 
           :update_promo_video, :add_coupon, :remove_coupon, :checkout_free, 
           :checkout_invitation, :checkout_restrict, :create_lead, :coupon_sent, :affiliate], Course
      can [:cart, :social], :checkout
    end

    if user.persisted?
      can [:notifications, :profile, :purchases, :edit_profile, 
        :courses_purchased, :mark_all_notifications_as_read, :messages], User do |this_user|
          this_user == user
      end

      can :dashboard_index, Course

      can [:register, :payment, :finish, 
            :failure, :finish_coupon, :pay_credit_card, 
            :pay_online_debit, :pay_billet, :finish_online_payment,
            :exception], :checkout

      can :create, Purchase

      can [:content, :show_media, :submit_message, :request_certificate, :ended], Course do |course|
        user.courses_as_student_within_validity.payment_confirmed.published.include?(course) ||
          user.courses_invited_within_validity.published.include?(course)
      end
    end
  end
end
