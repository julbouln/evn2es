require 'nova/record/req_contrib'
module Nova
  module Record
    class Govt
      extend Enum
      include Req

      def classes_govts
        self.classes.map do |cl|
          if cl > -1
            @files.governments_classes[cl]
          else
            []
          end
        end.flatten.uniq
      end

      def allies_govts
        self.allies.map do |ally|
          if ally > -1
            @files.governments_classes[ally]
          else
            []
          end
        end.flatten.uniq
      end

      def enemies_govts
        self.enemies.map do |enemy|
          if enemy > -1
            @files.governments_classes[enemy]
          else
            []
          end
        end.flatten.uniq
      end

      def hail_str_id
        @id - 128 + 7000
      end

      def flags_match(op)
        (self.flags.to_i & op) != 0
      end

      ## flags
      enum :Xenophobic, 0x0001 # Xenophobic (Warships of this govt attack everyone except their allies.
      # Useful for making pirates and other nasties.)
      enum :AttackCriminalPlayer, 0x0002 # Ships of this govt will attack the player in non-allied systems if he's a
      # criminal there (useful for making one govt care only about the player's
      # actions on its home turf, while another is nosy and enforces its own laws
      # everywhere it goes).
      enum :AlwaysAttackPlayer, 0x0004
      enum :PlayerWontHit, 0x0008 # Player's shots won't hit ships of this govt
      enum :WarshipRetreatWhenLowShield, 0x0010 # Warships of this govt will retreat when their shields drop below 25% -
      # otherwise they fight to the death.
      enum :IgnoreUnderAttack, 0x0020 # Nosy ships of other non-allied governments ignore ships
      # of this govt that are under attack.
      enum :NeverAttackPlayer, 0x0040
      enum :WarshipsTakeBribes, 0x0200
      enum :CantHail, 0x0400
      enum :Disabled, 0x0800
      # ...
      enum :WarshipPlunder, 0x1000 # Warships will plunder non-mission, non-player enemies before destroying them.
      enum :FreightersTakeBribes, 0x2000
      enum :PlanetsTakeBribes, 0x4000
      enum :ShipsTakeLargerBribes, 0x8000

      ## flags2
      enum :DoNotTalks, 0x0001 # When hailing ships of this govt, the request assistance / beg for mercy
      # button is disabled and the govt is not talkative.

    end
  end
end