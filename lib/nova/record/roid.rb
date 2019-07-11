module Nova
  module Record
    class Roid

      def spin
        @files.get(:spin, @id - 128 + 800)
      end
    end
  end
end
