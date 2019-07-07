module Nova
  module Record
    class Weap
      extend Enum
      belongs_to :sub_weap, type: :weap, key: :sub_type
      belongs_to :explosion, type: :boom, key: :explod_type, id_modifier: lambda {|boom_id|
        if boom_id >= 1000
          boom_id + 128 - 1000
        else
          boom_id + 128
        end
      }

      belongs_to :ammo_type, type: :weap, key: :ammo_type, id_modifier: lambda {|weap_id|
        weap_id + 128
      }

      belongs_to :spin, type: :spin, key: :graphic, id_modifier: lambda {|spin_id|
        spin_id + 3000
      }

      def unsupported
        self.guidance == Nova::Record::Weap::CarriedShip
      end

      def weap_outf
        if @files.weaps_to_outfits[@id]
          @files.weaps_to_outfits[@id]
        end
      end

      def ammo_outf
        if @files.ammos_to_outfits[@id]
          @files.ammos_to_outfits[@id]
        end
      end

      enum :Unguided, -1
      enum :Beam, 0
      enum :Homing, 1
      enum :TurretedBeam, 3
      enum :TurretedUnguided, 4
      enum :FreeFallBomb, 5
      enum :FreeFlightRocket, 6
      enum :FrontQuadrantTurret, 7
      enum :RearQuadrantTurret, 8
      enum :PointDefenseTurret, 9
      enum :PointDefenseBeam, 10
      enum :CarriedShip, 99

    end
  end
end
