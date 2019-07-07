module EvnToEs
  module Converter
    class Galaxies < Base
      def convert(nova)

        # buggy
        if false
          File.open(conv.data_export_path("galaxies.txt"), 'w') do |file|
            nova.traverse(:nebu) do |id, name, nebu|
              nebu.print_debug
              if nebu.initially_available
                conf = self.generate_config :galaxy, nebu.name do
                  entry :pos, nebu.x_pos * 2.0, nebu.y_pos * 2.0
                  entry :sprite, "pict/#{"%05d" % (9500 + (id - 128) * 7 + 2)}"
                end

                conf.write(file)
              end
            end
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("galaxies.txt"))
      end
    end
  end
end
