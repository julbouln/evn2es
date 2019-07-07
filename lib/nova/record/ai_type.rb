module Nova
  module Record
    class AiType
      extend Nova::Record::Enum
      enum :WimpyTrader, 1 # Visits planets and runs away when attacked
      enum :BraveTrader, 2 # Visits planets and fights back when attacked,
      # but runs away when his attacker is out of range.
      enum :Warship, 3 # Seeks out and attacks his enemies, or jumps out if there aren't any.
      enum :Interceptor, 4 # Seeks out his enemies, or parks in orbit around a planet if he can't find any.
      # Buzzes incoming ships to scan them for illegal cargo. Also acts as "piracy
      # police" by attacking any ship that fires on or attempts to board another,
      # non-enemy ship while the interceptor is watching.
    end
  end
end