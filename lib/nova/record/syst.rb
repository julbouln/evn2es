module Nova
  module Record
    class Syst
      test_expressions :visiblility

      belongs_to :govt, type: :govt, key: :govt
      has_few :cons, type: :syst, key: :con
      has_few :navs, type: :spob, key: :nav
      has_few :dudes, type: :dude, key: :dude_types, map: :probs, map_name: :prob

      def roids
        types = []
        if self.ast_types & 0x0001 != 0
          types << 128
        end
        if self.ast_types & 0x0002 != 0
          types << 129
        end
        if self.ast_types & 0x0004 != 0
          types << 130
        end
        if self.ast_types & 0x0008 != 0
          types << 131
        end
        if self.ast_types & 0x0010 != 0
          types << 132
        end
        if self.ast_types & 0x0020 != 0
          types << 133
        end
        if self.ast_types & 0x0040 != 0
          types << 134
        end
        if self.ast_types & 0x0080 != 0
          types << 135
        end
        if self.ast_types & 0x0100 != 0
          types << 136
        end
        if self.ast_types & 0x0200 != 0
          types << 137
        end
        if self.ast_types & 0x0400 != 0
          types << 138
        end
        if self.ast_types & 0x0800 != 0
          types << 139
        end
        if self.ast_types & 0x1000 != 0
          types << 140
        end
        if self.ast_types & 0x2000 != 0
          types << 141
        end
        if self.ast_types & 0x4000 != 0
          types << 142
        end
        if self.ast_types & 0x8000 != 0
          types << 143
        end
        types.map{|rid| @files.get(:roid, rid)}
      end
      memoize :roids

      def initially_available
        exp = Nova::TestExpression.new(@raw.visiblility)
        exp.set_initial_conditions!
        exp.resolve_to_true
      end

      memoize :initially_available
    end
  end
end
