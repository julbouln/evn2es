require 'forwardable'
require 'memoist'
require 'nova/raw'
require 'nova/raw/extra'

module Nova
  module Record
    module Enum
      def enum(key, value)
        @enum ||= {}
        @rev_enum ||= {}
        @enum[key] = value
        @rev_enum[value] = key
      end

      def sym(value)
        @rev_enum[value]
      end

      def const_missing(key)
        if @enum[key]
          @enum[key]
        else
          super
        end
      end
    end

    Nova::Raw.constants.each do |const|
      raw_class = Object.const_get "Nova::Raw::#{const.to_s}"
      c = Class.new do
        attr_accessor :id, :name, :raw

        extend Memoist

        extend Forwardable
        # delegates data to Raw
        raw_class.fields.map(&:name).each do |d|
          def_delegator :@raw, d
        end

        def initialize(id, name, raw, files)
          @id = id
          @name = name
          @raw = raw
          @files = files
        end

        def desc_id
          @id
        end

        def desc
          @files.get_desc(self.desc_id)
        end

        memoize :desc

        def set_expressions
          {}
        end

        def test_expressions
          {}
        end

        def self.set_expressions(*keys)
          define_method(:set_expressions) do
            exps = {}
            keys.each do |k|
              exps[k] = Nova::SetExpression.new(self.send(k).to_s, @files)
            end
            exps
          end
          memoize :set_expressions
        end

        def self.test_expressions(*keys)
          define_method(:test_expressions) do
            exps = {}
            keys.each do |k|
              exps[k] = Nova::TestExpression.new(self.send(k).to_s)
            end
            exps
          end
          memoize :test_expressions
        end

        def self.has_many(name, options)
          raise "Missing record type" unless options[:type]
          raise "Missing record key" unless options[:key]
          self_type = self.name.split('::').last.downcase.to_sym
          define_method(name) do
            # keep mapping in memory structure
            unless @files.mapping[self_type]
              @files.mapping[self_type] = {}
              @files.traverse(options[:type]) do |id, name, obj|
                res = obj.send(options[:key])
                if res.is_a? BinData::Array
                  res.each do |dest|
                    dest_id = dest.to_i
                    if dest_id > -1
                      @files.mapping[self_type][dest_id] ||= []
                      @files.mapping[self_type][dest_id] << id
                    end
                  end
                else
                  # if we use same belongs_to, it is already instanciated
                  dest_id = res.respond_to?(:to_i) ? res.to_i : res.id
                  if dest_id > -1
                    @files.mapping[self_type][dest_id] ||= []
                    @files.mapping[self_type][dest_id] << id
                  end
                end
              end
            end
            if @files.mapping[self_type][@id]
              @files.mapping[self_type][@id].map do |rec_id|
                @files.get(options[:type], rec_id)
              end
            else
              []
            end
          end
        end

        def self.belongs_to(name, options)
          raise "Missing record type" unless options[:type]
          raise "Missing record key" unless options[:key]
          offset = options[:offset] || 0
          superior_to = options[:superior_to] || -1
          conds = options[:conditions]
          define_method(name) do
            rec_id = nil
            if options[:key] == :self
              rec_id = @id + offset
            else
              rec_id = @raw.send(options[:key]) + offset
            end
            if options[:id_modifier]
              rec_id = options[:id_modifier].call(rec_id)
            end
            if rec_id > superior_to
              if !conds or conds.call(self)
                @files.get(options[:type], rec_id)
              end
            end
          end
          memoize name
        end

        def self.has_few(name, options)
          raise "Missing record type" unless options[:type]
          raise "Missing record key" unless options[:key]
          offset = options[:offset] || 0
          superior_to = options[:superior_to] || -1
          define_method(name) do
            i = 0
            @raw.send(options[:key]).map do |rid|
              obj = nil
              rec_id = rid + offset
              if rec_id > superior_to
                obj = @files.get(options[:type], rec_id)
                if options[:map] and options[:map_name]
                  map_val = @raw.send(options[:map])[i]
                  obj.instance_variable_set("@#{options[:map_name].to_s}".to_sym, map_val)
                  obj.define_singleton_method(options[:map_name]) do
                    eval "@#{options[:map_name].to_s}"
                  end
                end
              end
              i += 1
              obj
            end
          end
          memoize name
        end

        def type
          self.class.name.sub("Nova::Record::", "").downcase.to_sym
        end

        def shared_name
          self.name.sub(/\;.*/, "")
        end

        def uniq_name
          @files.name_from_id(self.type, @id)
        end

        def print_debug(keys = nil)
          str = ""
          @raw.snapshot.each do |k, v|
            if !keys or keys.include?(k)
              str += "#{k}: #{v} "
            end
          end
          puts "#{self.type.to_s.upcase} #{@id} #{@name} #{str}"
        end

        def unsupported
          false
        end

      end

      Record.const_set const, c
    end
  end
end

# High-level records
Dir[File.join(__dir__, 'record', '*.rb')].each {|file| require file}
