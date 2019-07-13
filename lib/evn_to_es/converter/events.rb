require 'evn_to_es/helper/system'
require 'evn_to_es/helper/planet'
module EvnToEs
  module Converter
    class Events < Base
      include EvnToEs::Helper::System
      include EvnToEs::Helper::Planet

      def convert(nova)
        File.open(conv.data_export_path("events.txt"), 'w') do |file|
          if self.conv.cheat
            conf = self.generate_config :event, "cheat event" do
              entry :date, 24, 6, 1177

              nova.traverse(:syst) do |id, name, syst|
                if syst.initially_available
                  entry "visit", syst.shared_name
                end
              end

              entry :set, "cheat"
            end
            conf.write(file)

            conf = self.generate_config :mission, "cheat" do
              entry :landing
              entry :invisible
              entry :to, :offer do
                entry :has, "cheat"
              end

              entry :on, :offer do
                entry "combat rating", :"=", 150
                entry :fail
              end
            end
            conf.write(file)
          end

          nova.traverse(:cron) do |id, name, cron|
            cron.print_debug if self.conv.verbose #([:random, :duration, :enable_on, :on_start, :on_end, :pre_holdoff, :post_holdoff])
            avail_bits = cron.enable_on.to_s.truncated.strip.downcase

            avail_exp = EvnToEs::TestExpression.new(avail_bits)
            has_event = cron.pre_holdoff > 0
            if has_event
              if cron.first_year > 0
                conf = self.generate_config :event, "#{name} trigger" do
                  entry :date, cron.first_day, cron.first_month, cron.first_year if cron.first_year > 0
                  entry :set, "#{name} triggered"
                end
                conf.write(file)
              end

              conf = self.generate_config :event, "#{name} start" do
                if cron.on_start.to_s.truncated.strip.length > 0
                  entry EvnToEs::SetExpressionEvent.new(cron.on_start.to_s, nova)
                end

                if cron.ind_news_str > 0
                  news_str = nova.get_str(cron.ind_news_str)
                  #puts "NEWS (IND) #{cron.ind_news_str} : #{news_str}"
                end

                cron.news_govt.each do |govt|
                  if govt and govt.news_str_id > 0
                    news_str = nova.get_str(govt.news_str_id)
                    news_name = news_str.first.match(/^News/) ? news_str.first.gsub(/([^\:]+)\:.*/, '\1') : "News"
                    #news_name = nova.resources[Nova::Type::STR][govt.news_str_id][:name]
                    #puts "NEWS #{govt.id} #{govt.name} #{govt.news_str_id} : #{news_str}"
                    entry :news, news_name do
                      entry :location do
                        entry :government, *govt.allies_govts.map(&:uniq_name)
                      end
                      entry :name do
                        entry :word do
                          entry news_name
                        end

                      end
                      entry :message do
                        entry :word do
                          entry news_str.first
                        end
                      end
                      if govt.news_pict > 0
                        entry :portrait do
                          entry "pict/#{"%05d" % govt.news_pict}"
                        end
                      end
                    end
                  end
                end
              end
              conf.write(file)

              conf = self.generate_config :event, "#{name} end" do
                if cron.on_end.to_s.truncated.strip.length > 0
                  entry EvnToEs::SetExpressionEvent.new(cron.on_end.to_s, nova)
                end
              end
              conf.write(file)
            end

            conf = self.generate_config :mission, name do
              entry :landing
              entry :invisible
              entry :repeat
              entry :to, :offer do
                if cron.random.to_i < 100
                  entry :random, :<, cron.random.to_i
                end
                if has_event
                  if cron.first_year > 0
                    entry :has, "#{name} triggered"
                  end
                end

                entry avail_exp
              end

              entry :on, :offer do
                if has_event
                  entry :event, "#{name} start", cron.pre_holdoff
                  entry :event, "#{name} end", cron.pre_holdoff + cron.duration
                else
                  if cron.on_start.to_s.truncated.strip.length > 0
                    entry EvnToEs::SetExpression.new(cron.on_start.to_s.truncated.strip, nova)
                  end
                end

                entry :fail
              end

            end
            conf.write(file)
          end

          # FIXME: what about reverse state ?
          i = 0
          nova.test_tree.each do |int, ops|
            name = "monitor state change #{i}"
            outfitters = {}
            shipyards = {}
            systs = []

            exp = EvnToEs::TestExpression.new(int)

            ini_exp = EvnToEs::TestExpression.new(int)
            ini_exp.set_initial_conditions!

            if false
              puts "EVENT #{name} #{int} -> #{exp.to_s}"
              exp.interpretation.each do |i|
                if i.is_a? Array
                  if i.first == :not
                    clr = "!#{i.last}"
                    puts "#{clr}: #{nova.set_tree[clr]}"
                  end
                end
              end
            end

            unless ini_exp.resolve_to_true
              conf = self.generate_config :mission, name do
                entry :landing
                entry :invisible
                entry :to, :offer do
                  entry exp
                end
                entry :on, :offer do
                  entry :event, "#{name} trigger"
                  entry :fail
                end
              end
              conf.write(file)

              ops.each do |t|
                obj = nova.get(t[:type], t[:id])
                case t[:type]
                when :outf
                  unless obj.unsupported
                    tech = "Tech level #{obj.tech_level}"
                    outfitters[tech] ||= []
                    outfitters[tech] << obj.uniq_name
                  end
                when :ship
                  case t[:test]
                  when :availability
                    tech = "Tech level #{obj.tech_level}"
                    shipyards[tech] ||= []
                    shipyards[tech] << obj.uniq_name
                  when :appear_on
                    # TODO
                  end
                when :syst
                  systs << obj
                when :flet
                  # TODO
                  #puts "FLEET EVENT : #{t} #{obj.uniq_name} #{obj.syst}"
                when :pers
                  # UNSUPPORTED
                  # puts "PERS EVENT : #{t} #{obj.uniq_name}"
                when :oops
                  # NEVER HAPPEN
                  # puts "OOPS EVENT : #{t} #{obj.uniq_name}"
                end
              end

              conf = self.generate_config :event, "#{name} trigger" do
                if outfitters.length > 0 or shipyards.length > 0 or systs.length > 0
                  outfitters.each do |tech, outfits|
                    entry :outfitter, tech do
                      outfits.each do |outfit|
                        entry :add, outfit
                      end
                    end
                  end
                  shipyards.each do |tech, ships|
                    entry :shipyard, tech do
                      ships.each do |ship|
                        entry :add, ship
                      end
                    end
                  end
                  systs.each do |syst|
                    syst.navs.each do |nav|
                      if nav and !nav.unsupported
                        entry :planet, nav.shared_name do
                          insert self.convert_spob(nova, nav)
                        end
                      end
                    end
                    entry :system, syst.shared_name do
                      insert self.convert_syst(nova, syst)
                    end
                  end
                else
                  #puts "WARN empty event trigger #{name} #{ops}"
                end

              end
              conf.write(file)
              i += 1
            end
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("events.txt"))
      end

    end
  end
end