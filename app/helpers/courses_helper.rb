#coding: utf-8

module CoursesHelper

	def payment_status_message course_item
		case course_item.status
		when :within_validity
			"<i class=\"icon-facetime-video\"></i> Assistir Curso".html_safe
		when :pending
			"<i class=\"icon-time\"></i> Pagamento #{course_item.purchase.payment_status}".html_safe
		when :out_of_date
			"<i class=\"icon-ban-circle\"></i> Período terminado".html_safe
		end
	end

	def payment_status_path course_item
		case course_item.status
		when :within_validity
			content_course_path(course_item.course)
		when :pending
			purchases_user_path
		when :out_of_date
			course_path(course_item.course)
		end
	end

	def payment_status_availabity_message course_item
		case course_item.status
		when :within_validity
			if course_item.limited?
				"Disponível até #{I18n.l(course_item.expires_at, format: :medium)}"
			else
				"Disponível indeterminadamente"
			end
		when :pending
			"Pagamento #{course_item.purchase.payment_status}"
		when :out_of_date
			"Período terminado em #{I18n.l(course_item.expires_at, format: :medium)}"
		end
	end

end
