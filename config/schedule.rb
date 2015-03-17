every :day, at: "13pm" do 
  runner "School.send_day_one_mail"
  runner "School.send_two_days_to_end_trial_mail"
  runner "School.send_end_trial_mail"
end
