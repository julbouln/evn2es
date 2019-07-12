require 'nova/record/req_contrib'
module Nova
  module Record
    class Ship
      include Req
      include Contrib

      belongs_to :shan, type: :shan, key: :self
      belongs_to :explosion1, type: :boom, key: :explode1, id_modifier: lambda {|boom_id|
        if boom_id >= 1000
          boom_id + 128 - 1000
        else
          boom_id + 128
        end
      }
      belongs_to :explosion2, type: :boom, key: :explode2, id_modifier: lambda {|boom_id|
        if boom_id >= 1000
          boom_id + 128 - 1000
        else
          boom_id + 128
        end
      }

      has_few :weaps1, type: :weap, key: :w_type, map: :w_count, map_name: :count
      has_few :weaps2, type: :weap, key: :w_type2, map: :w_count2, map_name: :count
      has_few :ammos, type: :weap, key: :w_type, map: :ammo, map_name: :count
      has_few :outfs1, type: :outf, key: :default_items, map: :item_count, map_name: :count
      has_few :outfs2, type: :outf, key: :default_items2, map: :item_count2, map_name: :count

      test_expressions :availability, :appear_on
      set_expressions :on_purchase, :on_capture, :on_retire

      def weaps
        self.weaps1 + self.weaps2
      end

      def outfs
        self.outfs1 + self.outfs2
      end

      def fighters
        fs = []
        self.ammos.each do |ammo|
          if ammo and ammo.ammo_outf
            if @files.ids_from_name(:ship, ammo.ammo_outf.name)
              fs << [ammo.ammo_outf.name, ammo.count]
            end
          end
        end
        fs
      end

      def desc_id
        @id - 128 + 13000
      end

      def initially_available
        exp = Nova::TestExpression.new(@raw.availability)
        exp.set_initial_conditions!
        exp.resolve_to_true
      end
      memoize :initially_available
    end
  end
end
