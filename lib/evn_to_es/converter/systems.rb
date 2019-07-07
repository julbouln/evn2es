module EvnToEs
  module Converter
    class Systems < Base
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

      def convert(nova)

        flets = []
        nova.traverse(:flet) do |fid, fname, flet|
          if flet.initially_available
            flets << flet
          end
        end

        File.open(conv.data_export_path("systems.txt"), 'w') do |file|
          nova.traverse(:syst) do |id, name, syst|
            syst.print_debug if self.conv.verbose

            if syst.initially_available
              conf = self.generate_config :system, name do
                entry :pos, syst.x_pos * 2.0, syst.y_pos * 2.0
                if syst.govt
                  entry :government, syst.govt.uniq_name
                else
                  entry :government, "Uninhabited"
                end
                syst.cons.each do |con|
                  if con and con.initially_available
                    entry :link, con.uniq_name
                  end
                end

                trades = Trades.new(nova)

                syst.navs.each do |nav|
                  if nav and !nav.unsupported
                    entry :object, nav.uniq_name do
                      dist = Math.sqrt(nav.x_pos ** 2 + nav.y_pos ** 2).round(2)
                      entry :sprite, conv.convert_rled((nav.spob_type > 58 ? nav.spob_type - 1 : nav.spob_type) + 2000, 0, "planet")
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

                entry :trade, "Food", trades.get_price("Food") if trades.get_commodity("Food")
                entry :trade, "Industrial", trades.get_price("Industrial") if trades.get_commodity("Industrial")
                entry :trade, "Medical Supplies", trades.get_price("Medical Supplies") if trades.get_commodity("Medical Supplies")
                entry :trade, "Luxury Goods", trades.get_price("Luxury Goods") if trades.get_commodity("Luxury Goods")
                entry :trade, "Metal", trades.get_price("Metal") if trades.get_commodity("Metal")
                entry :trade, "Equipment", trades.get_price("Equipment") if trades.get_commodity("Equipment")

                syst.dudes.each do |dude|
                  if dude
                    # ES: rand(factor) < 60
                    entry :fleet, dude.uniq_name, (100 - dude.prob) * 250
                  end
                end

                flets.each do |flet|
                  fname_ex = "#{flet.uniq_name} fleet"
                  case flet.syst.first
                  when :system
                    if flet.syst.last.id == id
                      entry :fleet, fname_ex, 10000
                    end
                  when :government
                    if syst.govt and flet.syst.last and flet.syst.last.id == syst.govt.id
                      entry :fleet, fname_ex, 15000
                    end
                  when :any_system
                    entry :fleet, fname_ex, 20000
                  end
                end

              end
              conf.write(file)
            end
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("systems.txt"))
        FileUtils.rm_rf("#{conv.images_export_dir}/planet")
      end

    end
  end
end
