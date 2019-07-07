module EvnToEs
  module Converter
    # TODO
    class Asteroids < Base
      def convert(nova)
        File.open(conv.data_export_path("asteroids.txt"), 'w') do |file|
          nova.traverse(:roid) do |id, name, roid|
            roid.print_debug if self.conv.verbose
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("asteroids.txt"))
      end

    end
  end
end
