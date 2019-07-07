require 'endless_sky'

module EvnToEs
  module Converter
    class Base
      include EndlessSky::Configurator
      attr_accessor :conv
      def initialize(conv)
        @conv = conv
      end

      def convert(nova)
      end

      def clean(nova)
      end

      def priority
        1000
      end
    end
  end
end
Dir[File.dirname(__FILE__) + '/converter/*.rb'].each {|file| require file}