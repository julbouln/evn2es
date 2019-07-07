module Nova
  module Record
    class Char
      has_few :start_sys, type: :syst, key: :start_system
      belongs_to :start_ship, type: :ship, key: :start_ship_type
    end
  end
end
