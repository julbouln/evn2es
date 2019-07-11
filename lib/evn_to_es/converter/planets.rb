require 'evn_to_es/helper/planet'
module EvnToEs
  module Converter
    class Planets < Base
      include EvnToEs::Helper::Planet

      def convert(nova)
        File.open(conv.data_export_path("planets.txt"), 'w') do |file|
          nova.traverse(:spob) do |id, name, spob|
            unless spob.unsupported
              spob.print_debug if self.conv.verbose
              conf = self.convert_spob(nova, spob)
              conf.write(file)
            end
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("planets.txt"))
        FileUtils.rm_rf("#{conv.images_export_dir}/land")
      end

    end
  end
end
