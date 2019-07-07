module Nova
  module Record
    module Req
      def require
        (self.require0.to_i.to_s(2).rjust(32, "0").reverse + self.require1.to_i.to_s(2).rjust(32, "0").reverse).split("").map{|b| b=="1" ? true : false}
      end
    end

    module Contrib
      def contribute
        (self.contributes0.to_i.to_s(2).rjust(32, "0").reverse + self.contributes1.to_i.to_s(2).rjust(32, "0").reverse).split("").map{|b| b=="1" ? true : false}
      end
    end
  end
end