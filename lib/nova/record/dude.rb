module Nova
  module Record
    class Dude
      belongs_to :govt, type: :govt, key: :govt
      has_few :ships, type: :ship, key: :ship_types, map: :probs, map_name: :prob
      has_many :misn_ships, type: :misn, key: :ship_dude
    end
  end
end
