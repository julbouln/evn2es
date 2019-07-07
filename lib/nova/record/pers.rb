require 'nova/record/position_resolver'
module Nova
  module Record
    class Pers
      extend Enum
      include PositionResolver

      belongs_to :govt, type: :govt, key: :govt, superior_to: 127
      belongs_to :ship, type: :ship, key: :ship_type
      belongs_to :misn, type: :misn, key: :link_mission
      has_few :weaps, type: :weap, key: :weap_type

      test_expressions :activate_on

      # flags
      enum :GrudgeIfAttacked, 0x0001 # The special ship will hold a grudge if attacked,
      # and will subsequently attack the player wherever the twain shall meet.
      enum :UseEscapePod, 0x0002 # Uses escape pod & has afterburner.
      enum :HailQuoteIfGrudge, 0x0004 # HailQuote only shown when ship has a grudge against the player.
      enum :HailQuoteIfLike, 0x0008 # HailQuote only shown when ship likes player.
      enum :HailQuoteWhenAttack, 0x0010 # Only show HailQuote when ship begins to attack the player.
      enum :HailQuoteWhenDisabled, 0x0020 # Only show HailQuote when ship is disabled.
      enum :ReplaceWithThisShip, 0x0040 # When LinkMission is accepted with a single SpecialShip, replace it with this
      # ship while removing this one from play. This is generally only useful for
      # escort and refuel-a-ship missions.
      enum :OnlyShowQuoteOnce, 0x0080
      enum :DeactivateShipAfterMission, 0x0100 # Deactivate ship (i.e. don’t make it show up again) after accepting its LinkMission.
      enum :MissionWhenBoarding, 0x0200 # Offer ship’s LinkMission when boarding it instead of when hailing it.

      # more


      def syst
        self.resolve_syst(self.link_syst)
      end
      memoize :syst
    end
  end
end
