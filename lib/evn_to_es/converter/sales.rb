module EvnToEs
  module Converter
    class Sales < Base

      def convert(nova)
        File.open(conv.data_export_path("sales.txt"), 'w') do |file|
          self.conv.get_shipyards.each do |shipyard_name, ships_names|
            conf = self.generate_config :shipyard, shipyard_name do
              ships_names.each do |ship_name|
                entry ship_name
              end
            end
            conf.write(file)
          end

          self.conv.get_outfitters.each do |outfitter_name, outfits_names|
            conf = self.generate_config :outfitter, outfitter_name do
              outfits_names.each do |outfit_name|
                entry outfit_name
              end
            end
            conf.write(file)
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("sales.txt"))
      end

    end
  end
end
