module EvnToEs
  module Converter
    # FOR DEBUG
    class Misc < Base
      def convert(nova)
        nova.resources[Nova::Type::STR].each do |id, res|
          strs = Nova::Raw::Str.read(res[:data])
          puts "STR# #{id} #{res[:name]} #{strs[:strings].length}" if self.conv.verbose
          puts strs[:strings].map {|str| str[:string].to_s.strip}.inspect if self.conv.verbose
        end

        nova.resources[Nova::Type::DESC].each do |id, res|
          puts "DESC #{id} #{res[:name]}" if self.conv.verbose
          puts res[:data].to_s.strip if self.conv.verbose
        end

        #nova.governments_classes.each do |cl, govts|
        #  puts "GOVT CLASS #{cl} : #{govts.map(&:uniq_name)}"
        #end
      end
    end
  end
end