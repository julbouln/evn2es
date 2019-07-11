module EvnToEs
  module Helper
    module System
      class Trades
        def initialize(nova)
          @trades = {}
          @indices = nova.get(:str, 4000).strings[0..5].map {|str| str[:string].to_s}
          @prices = nova.get(:str, 4004).strings.map {|str| str[:string].to_i}
        end

        def add_commodity(name, obj, low, med, high)
          idx = @indices.index(name)
          if idx
            if obj.flags_match(low)
              @trades[name] ||= []
              @trades[name] << (@prices[idx] * 0.5).round
            end
            if obj.flags_match(med)
              @trades[name] ||= []
              @trades[name] << @prices[idx]
            end
            if obj.flags_match(high)
              @trades[name] ||= []
              @trades[name] << (@prices[idx] * 2.0).round
            end
          end
        end

        def get_price(name)
          @trades[name].inject(0) {|s, v| s += v} / @trades[name].length
        end

        def get_commodity(name)
          @trades[name]
        end
      end

      def convert_syst(nova, syst)
        self.generate_config :system, syst.shared_name do
          entry :pos, syst.x_pos * 2.0, syst.y_pos * 2.0
          if syst.govt
            entry :government, syst.govt.uniq_name
          else
            entry :government, "Uninhabited"
          end
          syst.cons.each do |con|
            if con and con.initially_available
              entry :link, con.shared_name
            end
          end

          trades = Trades.new(nova)

          syst.navs.each do |nav|
            if nav and !nav.unsupported
              entry :object, nav.shared_name do
                dist = Math.sqrt(nav.x_pos ** 2 + nav.y_pos ** 2).round(2)
                entry :sprite, conv.convert_rled(nav.spin.sprites_id, 0, "planet")
                entry :distance, dist
                entry :period, 100.0
              end

              trades.add_commodity("Food", nav,
                                   Nova::Record::Spob::LowFoodPrice,
                                   Nova::Record::Spob::MediumFoodPrice,
                                   Nova::Record::Spob::HighFoodPrice
              )
              trades.add_commodity("Industrial", nav,
                                   Nova::Record::Spob::LowIndustrialPrice,
                                   Nova::Record::Spob::MediumIndustrialPrice,
                                   Nova::Record::Spob::HighIndustrialPrice
              )
              trades.add_commodity("Medical Supplies", nav,
                                   Nova::Record::Spob::LowMedicalPrice,
                                   Nova::Record::Spob::MediumMedicalPrice,
                                   Nova::Record::Spob::HighMedicalPrice
              )
              trades.add_commodity("Luxury Goods", nav,
                                   Nova::Record::Spob::LowLuxuryPrice,
                                   Nova::Record::Spob::MediumLuxuryPrice,
                                   Nova::Record::Spob::HighLuxuryPrice
              )
              trades.add_commodity("Metal", nav,
                                   Nova::Record::Spob::LowMetalPrice,
                                   Nova::Record::Spob::MediumMetalPrice,
                                   Nova::Record::Spob::HighMetalPrice
              )
              trades.add_commodity("Equipment", nav,
                                   Nova::Record::Spob::LowEquipmentPrice,
                                   Nova::Record::Spob::MediumEquipmentPrice,
                                   Nova::Record::Spob::HighEquipmentPrice
              )

            end
          end

          syst.roids.each do |roid|
            self.conv.convert_rled_frames(roid.spin.sprites_id, 0, 35, "asteroid/#{roid.id}", "-resize 200%", "spin")
            entry :asteroids, roid.id.to_s, syst.asteroids, (roid.spin_rate/30.0).round(3)
          end

          entry :trade, "Food", trades.get_price("Food") if trades.get_commodity("Food")
          entry :trade, "Industrial", trades.get_price("Industrial") if trades.get_commodity("Industrial")
          entry :trade, "Medical Supplies", trades.get_price("Medical Supplies") if trades.get_commodity("Medical Supplies")
          entry :trade, "Luxury Goods", trades.get_price("Luxury Goods") if trades.get_commodity("Luxury Goods")
          entry :trade, "Metal", trades.get_price("Metal") if trades.get_commodity("Metal")
          entry :trade, "Equipment", trades.get_price("Equipment") if trades.get_commodity("Equipment")

          syst.dudes.each do |dude|
            if dude
              # ES: rand(factor) < 60
              entry :fleet, dude.uniq_name, (100 - dude.prob) * 30
            end
          end

          nova.initial_flets.each do |flet|
            fname_ex = "#{flet.uniq_name} fleet"
            case flet.syst.first
            when :system
              if flet.syst.last.id == syst.id
                entry :fleet, fname_ex, 1500
              end
            when :government
              if syst.govt and flet.syst.last and flet.syst.last.id == syst.govt.id
                entry :fleet, fname_ex, 2500
              end
            when :any_system
              entry :fleet, fname_ex, 3000
            end
          end

        end
      end

    end
  end
end