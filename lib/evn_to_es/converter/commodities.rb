module EvnToEs
  module Converter
    class Commodities < Base
      def convert(nova)
        File.open(conv.data_export_path("commodities.txt"), 'w') do |file|
          conf = self.generate_config :trade, nil do
            prices = nova.get(:str, 4004).strings

            i=0
            nova.get(:str, 4000).strings[0..5].each do |c|
              entry :commodity, c[:string].to_s, prices[i][:string].to_i, prices[i][:string].to_i*2 do
                entry c[:string].to_s
              end
              i+=1
            end
            nova.get(:str, 4000).strings[6..-1].each do |c|
              entry :commodity, c[:string].to_s do
                entry c[:string].to_s
              end
            end
            # BUG in TradingPanel.cpp, we can't have too many commodity
            if false
              nova.traverse(:junk) do |id, name, junk|
                junk.print_debug([]) if self.conv.verbose
                entry :commodity, name, junk.base_price, (junk.base_price * 1.5).round do
                  entry name
                end
              end
            end

          end
          conf.write(file)
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("commodities.txt"))
      end

    end
  end
end