module EvnToEs
  module Converter
    class Hails < Base
      def convert(nova)
        File.open(conv.data_export_path("hails.txt"), 'w') do |file|

          conf = self.generate_config :phrase, "friendly disabled" do
            entry :word do
              entry "- disabled -"
            end
          end
          conf.write(file)

          conf = self.generate_config :phrase, "hostile disabled" do
            entry :word do
              entry "- disabled -"
            end
          end
          conf.write(file)

          nova.traverse(:govt) do |id, name, govt|
            conf = self.generate_config :phrase, "#{name} hails" do
              entry :word do
                strs = nova.get_str(govt.hail_str_id) || []
                strs.each do |str|
                  entry str.gsub(/\r/, " ")
                end
              end
            end
            conf.write(file)
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("hails.txt"))
      end

    end
  end
end
