#coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = FactoryGirl.create(:school_admin, first_name: "Augusto", last_name: "Zangrandi", password: "123456", email: "school_admin@email.com")
user.school = FactoryGirl.create(:school, name: "Academia Bizstart", subdomain: "bizstart", plan: "high", moip_login: "zangrandii@gmail.com", users: [user])
school = user.school
School.current_id = school.id
course = FactoryGirl.create(:course, title: "Como Montar o Seu Aquário")
course.update_attribute :logo, nil

