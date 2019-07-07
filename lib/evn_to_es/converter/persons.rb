require 'nova/raw/extra'

module EvnToEs
  module Converter
    class Persons < Base
      def convert(nova)
        File.open(conv.data_export_path("persons.txt"), 'w') do |file|

          if false
          nova.traverse(:flet) do |id, name, flet|
            flet.print_debug([]) if self.conv.verbose

            conf = self.generate_config :person, name do
              if flet.govt
                entry :government, flet.govt.uniq_name
              end

              if flet.syst
                case flet.syst.first
                when :system
                  entry :system, flet.syst.last.uniq_name
                when :government, :government_ally
                  if flet.syst.last
                    entry :system do
                      entry :government, flet.syst.last.uniq_name
                    end
                  end
                when :not_government
                  entry :system do
                    entry :not, :government, flet.syst.last.uniq_name
                  end
                else
                end
              end

              personalities = []
              if flet.govt
                personalities += Governments.govt_personalities(flet.govt)
              end

              if personalities.length > 0
                entry :personality do
                  personalities.each do |p|
                    entry p
                  end
                end
              end

              entry :ship, flet.lead_ship.uniq_name

              4.times do |i|
                if flet.escort_ships[i]
                  count = (flet.escort_min[i] + flet.escort_max[i]) / 2
                  count.to_i.times do |j|
                    entry :ship, flet.escort_ships[i].uniq_name
                  end
                end
              end
            end
            conf.write(file)
          end
          end

          nova.traverse(:pers) do |id, name, pers|
            pers.print_debug if self.conv.verbose
            conf = self.generate_config :person, name do
              entry :government, pers.govt.uniq_name if pers.govt

              personalities = []
              if pers.govt
                personalities += Governments.govt_personalities(pers.govt)
              end

              # pers.aggress, pers.coward
              case pers.ai_type
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

              if pers.aggress > 2
                personalities << :plunders
                personalities << :unconstrained
              end

              personalities.uniq!

              entry :personality do
                personalities.each do |p|
                  entry p
                end
              end

              if pers.syst
                case pers.syst.first
                when :system
                  entry :system, pers.syst.last.uniq_name
                when :government, :government_ally
                  entry :system do
                    entry :government, pers.syst.last.uniq_name
                  end
                when :not_government
                  entry :system do
                    entry :not, :government, pers.syst.last.uniq_name
                  end
                else
                end
              end

              entry :ship, pers.ship.uniq_name
            end
            conf.write(file)
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("persons.txt"))
      end

    end
  end
end
