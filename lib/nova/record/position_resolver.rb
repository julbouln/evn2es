module Nova
  module Record
    module PositionResolver

      def resolve_stel(id)
        case id
        when -1, 127
          [:no_specific_stellar, nil]
        when 128..2175
          [:stellar, @files.get(:spob, id)]
        when 5000..7047
          [:adj_system, @files.get(:syst, id - 5000 + 128)]
        when 9999
          [:any_government, nil]
        when 10000..10255
          [:government, @files.get(:govt, id - 10000 + 128)]
        when 15000..15255
          [:government_ally, @files.get(:govt, id - 15000 + 128)]
        when 20000..20255
          [:not_government, @files.get(:govt, id - 20000 + 128)]
        when 25000..25255
          [:government_ennemy, @files.get(:govt, id - 25000 + 128)]
        when 30000..30255
          [:government_class, @files.get(:govt, id - 30000 + 128)]
        when 31000..31255
          [:not_government_class, @files.get(:govt, id - 31000 + 128)]
        else
          puts "WARN unresolved stel #{id}"
          []
        end
      end

      def resolve_syst(id)
        case id
        when -1, 127
          [:any_system, nil]
        when 128..2175
          [:system, @files.get(:syst, id)]
        when 5000..7047
          [:adj_system, @files.get(:syst, id - 5000 + 128)]
        when 9999
          [:any_government, nil]
        when 10000..10255
          [:government, @files.get(:govt, id - 10000 + 128)]
        when 15000..15255
          [:government_ally, @files.get(:govt, id - 15000 + 128)]
        when 20000..20255
          [:not_government, @files.get(:govt, id - 20000 + 128)]
        when 25000..25255
          [:government_ennemy, @files.get(:govt, id - 25000 + 128)]
        when 30000..30255
          [:government_class, @files.get(:govt, id - 30000 + 128)]
        when 31000..31255
          [:not_government_class, @files.get(:govt, id - 31000 + 128)]
        else
          puts "WARN unresolved syst #{id}"
          []
        end
      end
    end
  end
end