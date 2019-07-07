module EvnToEs
  module Converter
    # FOR DEBUG
    class TestTree < Base
      def initialize(conv)
        super
      end

      def convert(nova)

        if false
          nova.test_tree.each do |op, vals|
            puts "TEST #{op}: #{vals}"
          end
          puts "TEST TOT #{nova.test_tree.length}"
          nova.set_tree.each do |op, vals|
            puts "SET #{op}: #{vals}"
          end
          puts "SET TOT #{nova.set_tree.length}"
        end

        if false
          [:cron, :misn, :ship, :outf, :junk, :nebu, :syst, :spob, :flet, :oops, :pers].each do |type|
            nova.traverse(type) do |id, name, obj|
              if true
                obj.set_expressions.each do |key, exp|
                  if exp.to_s.length > 0
                    puts "SET #{type} #{id} #{name} #{key} #{exp}=#{exp.interpretation}"
                  end
                end
              end
              if false
                obj.test_expressions.each do |key, exp|
                  if exp.to_s.length > 0
                    puts "TEST #{type} #{id} #{name} #{key} #{exp}=#{exp.interpretation}"
                  end
                end
              end

            end
          end
        end
      end
    end
  end
end