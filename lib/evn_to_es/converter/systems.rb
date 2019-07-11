require 'evn_to_es/helper/system'
module EvnToEs
  module Converter
    class Systems < Base
      include EvnToEs::Helper::System

      def convert(nova)
        File.open(conv.data_export_path("systems.txt"), 'w') do |file|
          nova.traverse(:syst) do |id, name, syst|
            syst.print_debug if self.conv.verbose

            if syst.initially_available
              conf = self.convert_syst(nova, syst)
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
