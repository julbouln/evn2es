require 'nova/record/position_resolver'
module Nova
  module Record
    class EscortShip
      attr_accessor :min, :max
    end
    class Flet
      extend Enum
      include PositionResolver

      belongs_to :govt, type: :govt, key: :govt
      belongs_to :lead_ship, type: :ship, key: :lead_ship_type
      has_few :escort_ships, type: :ship, key: :escort_ship_type, superior_to: 0

      test_expressions :activate_on

      enum :RandomCargo, 0x0001 # Freighters (InherentAI <= 2) in this fleet will have random cargo when boarded.

      def syst
        self.resolve_syst(self.link_syst)
      end
      memoize :syst

      def initially_available
        exp = Nova::TestExpression.new(@raw.activate_on)
        exp.set_initial_conditions!
        exp.resolve_to_true
      end
      memoize :initially_available
    end
  end
end
