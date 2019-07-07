module Nova
  module Record
    class Oops
      belongs_to :spob, type: :spob, key: :stellar

      test_expressions :activate_on
    end
  end
end
