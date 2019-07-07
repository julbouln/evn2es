module EndlessSky
  class Config
    attr_accessor :key, :values, :children, :context

    def initialize(*val, &block)
      @values = val
      @children = []
    end

    def write(io, level = 0)
      if @values.length > 0 or @children.length > 0
        @values.each_with_index do |v, idx|
          case v
          when String
            io.write("\t" * level) if idx == 0
            io.write("\"#{v}\"")
            io.write(" ")
          when EvnToEs::ConversationLine, EvnToEs::Description, EvnToEs::Conversation, EvnToEs::MultiLineDescription,
              EvnToEs::TestExpression, EvnToEs::SetExpression, EvnToEs::SetExpressionEvent
            v.write(io, level)
          else
            io.write("\t" * level) if idx == 0
            io.write(v)
            io.write(" ")
          end
        end
        unless self.values.last.respond_to?(:endline)
          io.write("\n")
        end
        @children.each do |child|
          child.write(io, level + 1)
        end
      end
    end

    def entry *val, &block
      child = self.class.new *val
      child.context = @context
      if block_given?
        child.instance_eval(&block)
      end
      @children << child
    end

    def insert conf
      @children += conf.children
    end

    def method_missing method, *args, &block # :nodoc:
      if @context && @context.respond_to?(method)
        @context.send(method, *args, &block)
      else
        super
      end
    end
  end

  module Configurator
    def generate_config *val, &block
      parent = Config.new *val
      parent.context = eval('self', block.binding)
      parent.instance_eval(&block)
      parent
    end
  end
end
