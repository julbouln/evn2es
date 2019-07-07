module EvnToEs
  module Converter
    class Ratings < Base
      def convert(nova)
        strs = nova.get_str(138)
        File.open(conv.data_export_path("ratings.txt"), 'w') do |file|
          conf = self.generate_config :rating, "combat" do
            strs.each do |rat|
              entry rat
            end
          end

          conf.write(file)
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("ratings.txt"))
      end

    end
  end
end

