class ActiveSupport::TimeWithZone
	def br_time_format
		self.strftime("%d/%m/%Y %H:%M")
	end

	def br_date_format
		self.strftime("%d/%m/%Y")
	end
end

class Numeric
	def em_real
    value = self.to_s
    if value.include? "."
      value = value.split(".").first
    else
      value = value.gsub(/\D+/, "")
    end
    if value.length == 1
      "R$ 0,0" + value
    elsif value.length == 2
      "R$ 0," + value
    elsif value.length > 2
  		"R$ " + value.insert(-3, ',')
    end
  end
end