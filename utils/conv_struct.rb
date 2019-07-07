require 'cast'
require 'pp'

# https://github.com/nickshanks/ResKnife/blob/master/NovaTools/Structs.h
class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr("-", "_").
        downcase
  end
end

class CStructToBindata
  def initialize
  end

  def reserved
    ["max", "length", "count"]
  end

  def conv_type(type)
    case type.to_s
    when "short int"
      "int16"
    when "long int"
      "int32"
    when "char"
      "uint8"
    when "struct Rect"
      "rect"
    else
      "TODO #{type}"
    end
  end

  def name(decl)
    nm = decl.name.underscore
    if self.reserved.include?(nm)
      nm = nm + "_"
    end
    nm
  end

  def convert
    source = File.read("Structs.h")
    ast = C.parse(source)
    puts "# automatically generated, do not edit"
    puts "require 'bindata'"
    puts "module Nova"
    puts " module Raw"
    ast.entities.each do |declaration|
      struct = declaration.type
      puts ""
      puts "  class #{struct.name.gsub(/Rec$/, '')} < BinData::Record"
      puts "   endian :big"
      struct.members.each do |member|
        decl = member.declarators.first
        rb_code = "   #{self.conv_type(member.type)} :#{self.name(decl)}"

        if decl.indirect_type.class == C::Array
          if member.type.to_s == "char"
            rb_code = "   string :#{self.name(decl)}, length: #{decl.indirect_type.length}, trim_padding: true"
          else
            rb_code = "   array :#{self.name(decl)}, type: :#{self.conv_type(member.type)}, initial_length: #{decl.indirect_type.length}"
          end
        end
        puts rb_code
      end
      puts "  end"
    end
    puts " end"
    puts "end"
  end
end

conv = CStructToBindata.new
conv.convert
