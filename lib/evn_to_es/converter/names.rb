module EvnToEs
  module Converter
    class Hails < Base
      def convert(nova)
        File.open(conv.data_export_path("names.txt"), 'w') do |file|
          nova.traverse(:govt) do |id, name, govt|
            conf = self.generate_config :phrase, "#{name} hails" do
              entry :word do
                strs = nova.get_str(govt.hail_str_id) || []
                strs.each do |str|
                  entry str.gsub(/\r/," ")
                end
              end
            end
            conf.write(file)
          end
        end
      end
    end
  end
end
