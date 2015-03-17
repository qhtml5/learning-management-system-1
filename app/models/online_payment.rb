class OnlinePayment
	attr_accessor :form, :institution

	def initialize form, opts = {}
		self.form = form
		self.institution = opts[:institution]
	end

	def to_json
		json = {
			Forma: @form,
			Instituicao: @institution
		}

		json
	end
end