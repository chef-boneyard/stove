module Stove
  module Mixin::Validatable
    def validate(id, &block)
      Runner.validations << Validator.new(self, id, &block)
    end
  end
end
