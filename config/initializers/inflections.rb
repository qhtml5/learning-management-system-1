#coding: utf-8

ActiveSupport::Inflector.inflections do |inflect|
  inflect.clear

  inflect.plural(/$/, 's')
  inflect.plural(/([sxz]|[cs]h)$/i, '\1es')
  inflect.plural(/([^aeiouy]o)$/i, '\1es')
  inflect.plural(/([^aeiouy])y$/i, '\1ies')

  inflect.singular(/s$/i, '')
  inflect.singular(/(ss)$/i, '\1')
  inflect.singular(/([sxz]|[cs]h)es$/, '\1')
  inflect.singular(/([^aeiouy]o)es$/, '\1')
  inflect.singular(/([^aeiouy])ies$/i, '\1y')

  inflect.uncountable(%w(series))

  inflect.irregular('child', 'children')
  inflect.irregular('person', 'people')
  inflect.irregular('self', 'selves')
  inflect.irregular('purchase', 'purchases')
  inflect.irregular('course', 'courses')
  inflect.irregular('cart', 'carts')
  inflect.irregular('cart_item', 'cart_items')

  inflect.irregular 'free_course', 'free_courses'
  inflect.irregular 'FreeCourse', 'FreeCourses'

  inflect.irregular 'course_user', 'courses_users'
  inflect.irregular 'CourseUser', 'CoursesUsers'

  inflect.irregular 'classroom_course', 'classroom_courses'
  inflect.irregular 'ClassroomCourse', 'ClassroomCourses'

  inflect.irregular 'lesson_media', 'lessons_medias'
  inflect.irregular 'LessonMedia', 'LessonsMedias'

  inflect.irregular 'message_answer', 'messages_answers'
  inflect.irregular 'MessageAnswer', 'MessagesAnswers'

  inflect.irregular 'tag_user', 'tags_users'
  inflect.irregular 'TagUser', 'TagsUsers'

  inflect.irregular 'course_category', 'course_categories'
  inflect.irregular 'CourseCategory', 'CourseCategories'

  inflect.irregular 'curso', 'cursos'
end