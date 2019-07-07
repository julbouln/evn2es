require 'nova/record/position_resolver'
require 'nova/record/req_contrib'
module Nova
  module Record
    class Misn
      extend Enum
      include PositionResolver
      include Req

      test_expressions :avail_bits
      set_expressions :on_accept, :on_refuse, :on_success, :on_failure, :on_abort, :on_ship_done

      belongs_to :comp_govt, type: :govt, key: :comp_govt, superior_to: 127
      belongs_to :ship_dude, type: :dude, key: :ship_dude
      belongs_to :aux_ship_dude, type: :dude, key: :aux_ship_dude

      has_many :perss, type: :pers, key: :link_mission

      # pickup mode
      enum :PickupAtMissionStart, 0
      enum :PickupAtTravelStel, 1
      enum :PickupWhenBoardingShip, 2

      # dropoff mode
      enum :DropOffAtTravelStel, 0
      enum :DropOffAtMissionStel, 1 # ReturnStel

      # ship goal
      enum :ShipGoalDestroy, 0
      enum :ShipGoalDisable, 1
      enum :ShipGoalBoard, 2
      enum :ShipGoalEscort, 3
      enum :ShipGoalObserve, 4
      enum :ShipGoalRescue, 5
      enum :ShipGoalChase, 6

      # ship behave
      enum :ShipBehaveAlwaysAttack, 0
      enum :ShipBehaveProtect, 1
      enum :ShipBehaveDestroyStellar, 2

      # AvailLoc
      enum :AvailFromMissionComputer, 0
      enum :AvailInBar, 1
      enum :AvailFromShip, 2
      enum :AvailInMainDialog, 3
      enum :AvailInTradingDialog, 4
      enum :AvailInShipyardDialog, 5
      enum :AvailInOutfitDialog, 6

      # flags
      enum :DontShowArrow, 0x0002
      enum :CantRefuse, 0x0004
      # ...
      enum :Invisible, 0x0400

      def flags_match(op)
        (self.flags.to_i & op) != 0
      end

      def desc_id
        @id - 128 + 4000
      end

      def src
        self.resolve_stel(self.avail_stel)
      end
      memoize :src

      def ret
        self.resolve_stel_dest(self.return_stel)
      end
      memoize :ret

      def trav
        self.resolve_stel_dest(self.travel_stel)
      end
      memoize :trav

      def _resolve_ship_syst(id)
        case id
        when -1
          [:initial_system, nil]
        when -2
          [:any_random_system, nil]
        when -3
          [:travel_system, nil]
        when -4
          [:return_system, nil]
        when -5
          [:adj_system, nil]
        when -6
          [:player_system, nil]
        else
          resolve_syst(id)
        end
      end

      def resolve_ship_syst
        self._resolve_ship_syst(self.ship_syst)
      end

      def resolve_aux_ship_syst
        self._resolve_ship_syst(self.aux_ship_syst)
      end

      def resolve_stel_dest(stel)
        case stel
        when -2
          [:random_inhabited_stellar, nil]
        when -3
          [:random_uninhabited_stellar, nil]
        when -4
          [:initial_stellar, nil]
        else
          resolve_stel(stel)
        end
      end

      def avail_ship
        if self.avail_ship_type > 0
          @files.get(:ship, self.avail_ship_type)
        end
      end


    end
  end
end