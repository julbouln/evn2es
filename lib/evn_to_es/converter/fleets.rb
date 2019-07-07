module EvnToEs
  module Converter
    class Fleets < Base
      def convert(nova)
        File.open(conv.data_export_path("fleets.txt"), 'w') do |file|
          if true
            nova.traverse(:flet) do |id, name, flet|
              if flet.initially_available
                flet.print_debug if self.conv.verbose

                conf = self.generate_config :fleet, "#{name} fleet" do
                  if flet.govt
                    entry :government, flet.govt.uniq_name
                  end
                  personalities = []

                  if flet.govt
                    personalities += Governments.govt_personalities(flet.govt)
                  end

                  personalities.uniq!

                  entry :personality do
                    personalities.each do |p|
                      entry p
                    end
                  end

                  variants_h = {}
                  4.times do |i|
                    if flet.escort_ships[i]
                      cnt_variants = ((flet.escort_min[i].to_i)..(flet.escort_max[i].to_i)).to_a
                      cnt_variants.each do |cnt|
                        variants_h[flet.escort_ships[i].id] ||= []
                        variants_h[flet.escort_ships[i].id] << cnt
                        variants_h[flet.escort_ships[i].id].uniq!
                      end
                    end
                  end

                  max = variants_h.to_a.sort {|v| v.last.length}.first.last.length

                  # TODO: need improvements
                  max.times do |i|
                    variants_h.each do |shid_i, cnts_i|
                      entry :variant, 1 do

                        entry flet.lead_ship.uniq_name, 1

                        if cnts_i[i] and cnts_i[i] > 0
                          sh = nova.get(:ship, shid_i)
                          entry sh.uniq_name, cnts_i[i]
                        end
                        variants_h.each do |shid, cnts|
                          if shid_i != shid
                            if cnts[i] and cnts[i] > 0
                              sh = nova.get(:ship, shid)
                              entry sh.uniq_name, cnts[i]
                            end
                          end
                        end
                      end
                    end
                  end
                end
                conf.write(file)
              end
            end
          end

          nova.traverse(:dude) do |id, name, dude|
            dude.print_debug if self.conv.verbose
            conf = self.generate_config :fleet, name do
              if dude.govt
                entry :government, dude.govt.uniq_name
              end

              personalities = []

              if dude.govt
                personalities += Governments.govt_personalities(dude.govt)
              end

              case dude.ai_type
              when Nova::Record::AiType::WimpyTrader
                personalities << :timid
              when Nova::Record::AiType::BraveTrader
                personalities << :forbearing
              when Nova::Record::AiType::Warship
                personalities << :heroic
              when Nova::Record::AiType::Interceptor
                personalities << :heroic
                personalities << :vindictive
              end

              personalities.uniq!

              entry :personality do
                personalities.each do |p|
                  entry p
                end
              end

              dude.ships.each do |ship|
                if ship
                  entry :variant, ship.prob do
                    entry ship.uniq_name, 1
                  end
                end
              end
            end
            conf.write(file)
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("fleets.txt"))
      end

    end
  end
end