module EvnToEs
  module Converter
    class Start < Base
      def convert(nova)
        if true
          File.open(conv.data_export_path("start.txt"), 'w') do |file|
            nova.traverse(:char) do |id, name, char|
              char.print_debug if self.conv.verbose
              conf = self.generate_config :start do
                entry :date, char.start_day, char.start_month, char.start_year
                entry :system, char.start_sys.first.uniq_name
                entry :planet, char.start_sys.first.navs.first.uniq_name

                if self.conv.cheat
                  entry :ship, "Kestrel", "Cardinal Virtue"
                else
                  entry :ship, char.start_ship.uniq_name, "Cardinal Virtue"
                end

                entry :account do
                  if self.conv.cheat
                    entry :credits, 1000000
                  else
                    entry :credits, char.start_cash
                  end
                end
              end
              conf.write(file)

              conf = self.generate_config :conversation, "intro" do
                entry EvnToEs::ConversationLine.new("Enter your name")
                entry :name
                char.intro_pict_id.each do |pict|
                  if pict > -1
                    entry :scene, self.conv.convert_pict(pict, "intro", "-resize 540x")
                  end
                end
#                entry EvnToEs::Conversation.new("Go")
              end
              conf.write(file)
            end
          end
        end
      end

      def clean(nova)
        FileUtils.rm_rf("#{conv.images_export_dir}/intro")
      end
    end
  end
end

