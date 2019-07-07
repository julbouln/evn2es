module Nova
  module Record
    class Syst
      test_expressions :visiblility

      belongs_to :govt, type: :govt, key: :govt
      has_few :cons, type: :syst, key: :con
      has_few :navs, type: :spob, key: :nav
      has_few :dudes, type: :dude, key: :dude_types, map: :probs, map_name: :prob

      def initially_available
        exp = Nova::TestExpression.new(@raw.visiblility)
        exp.set_initial_conditions!
        exp.resolve_to_true
      end

      memoize :initially_available
    end
  end
end
