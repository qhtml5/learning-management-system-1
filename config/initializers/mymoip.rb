module MyMoip
  class JsonParser
    def self.call(body, format)
      if format == :json
        body_match = body.match(/\?\((?<valid_json>.+)\)/)
        if body_match.present?
          JSON.parse body.match(/\?\((?<valid_json>.+)\)/)[:valid_json]
        else
          body
        end
      else
        body
      end
    end
  end

	class Commission
		def to_xml(root = nil)
      raise InvalidComission if invalid?

      if root.nil?
        xml  = ""
        root ||= Builder::XmlMarkup.new(target: xml)
      end

      root.Comissionamento do |n1|
        n1.Razao(reason)
        n1.Comissionado {|n2| n2.LoginMoIP(receiver_login)}
        n1.ValorFixo(fixed_value) if fixed_value
        n1.ValorPercentual(percentage_value*100) if percentage_value
      end

      xml
		end
	end

end

MyMoip::CreditCard.class_eval do
  _validators.reject!{ |key, _| key == :expiration_date }

  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes == [:expiration_date]
  end
end
