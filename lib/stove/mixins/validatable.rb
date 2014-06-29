module Stove
  module Mixin::Validatable
    def validate(id, &block)
      validations[id] = Validator.new(self, id, &block)
    end

    def validations
      @validations ||= {}
    end
  end
end
