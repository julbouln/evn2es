module Nova
  module Record
    class Nebu
      test_expressions :active_on
      set_expressions :on_explore

      def initially_available
        exp = Nova::TestExpression.new(@raw.active_on)
        exp.set_initial_conditions!
        exp.resolve_to_true
      end

      memoize :initially_available
    end
  end
end
