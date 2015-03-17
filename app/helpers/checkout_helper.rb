#coding: utf-8

module CheckoutHelper

	def calculate_installments value, installments
    result = []
    moip_taxes.first(installments.to_i).each_with_index do |c, i|
      i += 1
      tax_message = i == 1 ? "s/ juros" : "c/ juros"
      value_with_tax = (value * c).round(2)
      installment = (value_with_tax / i).round(2)
      if i == 1
        result << ["#{i}x de #{em_real(installment)} #{tax_message}", i]
      else
        result << ["#{i}x de #{em_real(installment)} #{tax_message} (#{em_real(value_with_tax)})", i]
      end
    end
    result
  end

  def max_installments_value total
    em_real((total * moip_taxes[installments_amount(total) - 1]) / installments_amount(total).round(2))
  end

  def installments_amount total
    result = total / 500.0
    if result >= 12
      12
    elsif result.to_i == 0
      1
    else
      result.to_i
    end 
  end

  def moip_taxes
  	[1, 1.0299, 1.0401, 1.0502, 
     1.0605, 1.07076, 1.08122, 
     1.0917, 1.10214, 1.1126, 
     1.12332, 1.134]
  end

end