require 'nova/record/req_contrib'
module Nova
  module Record
    class Mod
      attr_accessor :type, :val

      def initialize(mod_type, mod_val, files)
        @type = mod_type.to_i
        @val = mod_val.to_i
        @files = files
      end

      def record
        case @type
        when Outf::Weapon
          @files.get(:weap, @val)
        when Outf::Ammunition
          @files.get(:weap, @val)
        when Outf::CleanLegalRecord
          @files.get(:govt, @val)
        when Outf::IncreaseMaximum
          @files.get(:outf, @val)
        else
          nil
        end
      end
    end

    class Outf
      extend Enum
      include Req
      include Contrib
      belongs_to :weap, type: :weap, key: :mod_val

      test_expressions :availability
      set_expressions :on_purchase, :on_sell

      def mods
        [
            Mod.new(self.mod_type, self.mod_val, @files),
            Mod.new(self.mod_type2, self.mod_val2, @files),
            Mod.new(self.mod_type3, self.mod_val3, @files),
            Mod.new(self.mod_type4, self.mod_val4, @files)
        ]
      end

      def unsupported
        (self.weap and self.weap.unsupported) or
            self.mod_type == Nova::Record::Outf::EscapePod or
            self.mod_type == Nova::Record::Outf::AutoEject or
            self.mod_type == Nova::Record::Outf::DensityScanner or
            self.mod_type == Nova::Record::Outf::IFF or
            self.mod_type == Nova::Record::Outf::MultiJump or
            self.mod_type == Nova::Record::Outf::AutoRefueller
      end

      def flags_match(flag)
        (self.flags & flag) != 0
      end

      # flags
      enum :ItemIsFixedGun, 0x0001
      enum :ItemIsTurret, 0x0002
      enum :ItemStays, 0x0004 # This item stays with you when you trade ships (persistent).
      enum :ItemCantBeSold, 0x0008
      enum :ItemRemoveOther, 0x0010 # Remove any items of this type after purchase (useful for permits and other
      # intangible purchases).
      enum :ItemIsPersistent, 0x0020 # This item is persistent in the case where the player's ship is changed by a
      # mission set operator. The item's normal persistence for when the player buys
      # or captures a new ship is still controlled by the 0x0004 bit.
      enum :ItemDontShow, 0x0100 # Don't show this item unless the player meets the Require bits, or already has
      # at least one of it.
      enum :ItemProportionalPrice, 0x0200 # This item's total price is proportional to the player's ship's mass. (ship class
      # Mass field is multiplied by this item's Cost field)
      enum :ItemProportionalMass, 0x0400 # This item's total mass (at purchase) is proportional to the player's ship's
      # mass. (ship class Mass field is multiplied by this item's Mass field and then
      # divided by 100) Only works for positive-mass items.
      enum :ItemSoldAnywhere, 0x0800 # This item can be sold anywhere, regardless of tech level, requirements, or
      # mission bits.
      enum :ItemPreventHigh, 0x1000 # When this item is available for sale, it prevents all higher-numbered items
      # with equal DispWeight from being made available for sale at the same time.
      enum :ItemInRank, 0x2000 # This outfit appears in the Ranks section of the player info dialog instead of
      # in the Extras section.
      enum :ItemDontShow2, 0x4000 # Don't show this item unless its Availability evaluates to true, or if the player
      # already has at least one of it.


      # outfit types
      enum :None, -1
      enum :Weapon, 1
      enum :MoreCargoSpace, 2
      enum :Ammunition, 3
      enum :MoreShieldCapacity, 4
      enum :FasterShieldRecharge, 5
      enum :Armour, 6
      enum :AccelerationBooster, 7
      enum :SpeedIncrease, 8
      enum :TurnRateChange, 9
      enum :Unused, 10
      enum :EscapePod, 11
      enum :FuelCapacityIncrease, 12
      enum :DensityScanner, 13
      enum :IFF, 14
      enum :Afterburner, 15
      enum :Map, 16
      enum :CloakingDevice, 17
      enum :FuelScoop, 18
      enum :AutoRefueller, 19
      enum :AutoEject, 20
      enum :CleanLegalRecord, 21
      enum :HyperspaceSpeedMod, 22
      enum :HyperspaceDistMod, 23
      enum :InterferenceMod, 24
      enum :Marines, 25
      enum :Ignored, 26
      enum :IncreaseMaximum, 27
      enum :MurkModifier, 28
      enum :FasterArmourRecharge, 29
      enum :CloakScanner, 30
      enum :MiningScoop, 31
      enum :MultiJump, 32
      enum :JammingType1, 33
      enum :JammingType2, 34
      enum :JammingType3, 35
      enum :JammingType4, 36
      enum :FastJumping, 37
      enum :InertialDampener, 38
      enum :IonDissipater, 39
      enum :IonAbsorber, 40
      enum :GravityResistance, 41
      enum :ResistDeadlyStellars, 42
      enum :Paint, 43
      enum :ReinfInhibitor, 44
      enum :ModifyMaxGuns, 45
      enum :ModifyMaxTurrets, 46
      enum :Bomb, 47
      enum :IFFScrambler, 48
      enum :RepairSystem, 49
      enum :NonlethalBomb, 50


      def desc_id
        @id - 128 + 3000
      end

      def pict_id
        @id - 128 + 6000
      end

      def initially_available
        exp = Nova::TestExpression.new(@raw.availability)
        exp.set_initial_conditions!
        exp.resolve_to_true
      end

      memoize :initially_available
    end
  end
end
