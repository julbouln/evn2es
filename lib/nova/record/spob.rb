module Nova
  module Record
    class Spob
      extend Nova::Record::Enum

      set_expressions :on_dominate, :on_release, :on_destroy, :on_regen
      belongs_to :govt, type: :govt, key: :govt, superior_to: 127
      has_few :hyperlinks, type: :spob, key: :hyper_link
      has_many :systs, type: :syst, key: :nav

      def bar_desc_id
        @id - 128 + 10000
      end

      def unsupported
        self.flags2_match(Nova::Record::Spob::IsHypergate) or
            self.flags2_match(Nova::Record::Spob::IsWormhole)
      end

      def flags_match(op)
        (self.flags.to_i | op) == self.flags.to_i
      end

      def flags2_match(op)
        (self.flags2.to_i & op) != 0
      end

      # flags
      # Perform an OR operation on the following flags to get the final flag value
      enum :CanLandDock, 0x00000001
      enum :HasCommodityExchange, 0x00000002
      enum :CanOutfit, 0x00000004
      enum :CanBuyShips, 0x00000008
      enum :StellarIsStation, 0x00000010
      enum :StellarIsUninhabited, 0x00000020
      enum :HasBar, 0x00000040
      enum :LandIfDestroyed, 0x00000080

      enum :WontTradeFood, 0x00000000
      enum :LowFoodPrice, 0x10000000
      enum :MediumFoodPrice, 0x20000000
      enum :HighFoodPrice, 0x40000000

      enum :WontTradeIndustrial, 0x00000000
      enum :LowIndustrialPrice, 0x01000000
      enum :MediumIndustrialPrice, 0x02000000
      enum :HighIndustrialPrice, 0x04000000

      enum :WontTradeMedical, 0x00000000
      enum :LowMedicalPrice, 0x00100000
      enum :MediumMedicalPrice, 0x00200000
      enum :HighMedicalPrice, 0x00400000

      enum :WontTradeLuxury, 0x00000000
      enum :LowLuxuryPrice, 0x00010000
      enum :MediumLuxuryPrice, 0x00020000
      enum :HighLuxuryPrice, 0x00040000

      enum :WontTradeMetal, 0x00000000
      enum :LowMetalPrice, 0x00001000
      enum :MediumMetalPrice, 0x00002000
      enum :HighMetalPrice, 0x00004000

      enum :WontTradeEquipment, 0x00000000
      enum :LowEquipmentPrice, 0x00000100
      enum :MediumEquipmentPrice, 0x00000200
      enum :HighEquipmentPrice, 0x00000400

      # flags2
      # more
      enum :IsDestroyed, 0x0040
      # more
      enum :IsHypergate, 0x1000
      enum :IsWormhole, 0x2000
      # more
    end
  end
end