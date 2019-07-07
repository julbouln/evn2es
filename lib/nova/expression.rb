# https://github.com/aarongough/sexpistol
require 'strscan'
module Nova

  class ExpressionMissingParentheses < StandardError
  end

  class ExpressionInvalidPosition < StandardError
  end

  class ExpressionParser < StringScanner

    def initialize(string)
      unless (string.count('(') == string.count(')'))
        raise ExpressionMissingParentheses
      end
      super(string)
    end

    def parse
      exp = []
      while true
        case fetch_token
        when '('
          exp << parse
        when ')'
          break
        when String, Fixnum, Float, Symbol
          exp << @token
        when nil
          break
        end
      end
      exp
    end

    def fetch_token
      skip(/\s+/)
      return nil if (eos?)

      @token =
          # Match parentheses
          if scan(/[\(\)]/)
            matched
            # Match a symbol
          elsif scan(/[^\(\)\s]+/)
            matched.to_s
            # If we've gotten here then we have an invalid token
          else
            near = scan %r{.{0,20}}
            raise ExpressionInvalidPosition, "Invalid character at position #{pos} near '#{near}'."
          end
    end
  end

  class Expression
    def recursive_map(data, &block)
      if (data.is_a?(Array))
        return data.map do |x|
          if (x.is_a?(Array))
            recursive_map(x, &block)
          else
            block.call(x)
          end
        end
      else
        block.call(data)
      end
    end
  end

  class SetExpression < Expression
    attr_accessor :interpretation
    # Parse a string containing an S-Expression into a
    # nested set of Ruby arrays
    def initialize(exp, files)
      @exp = exp.truncated.downcase.strip
      @tree = ExpressionParser.new(@exp).parse
      @interpretation = interpret(@tree)
      @files = files
    end

    def to_s
      @exp
    end

    def inspect
      "\"#{@exp}\" #{@interpretation}"
    end

    def interpret(expression)
      return recursive_map(expression) do |x|
        case x
        when /^b/ then
          # set bit
          [:set_bit, x]
        when /^!b/ then
          # clear bit
          [:clear_bit, x.delete("!")]
        when /^\^b/ then
          # toggle bit
          [:toggle_bit, x.delete("^")]
        when /^r/ then
          # TODO
          [:random, nil]
        when /^a/ then
          # misn
          # if mission ID xxx is currently active, abort it.
          [:abort_mission, x.delete("a").to_i]
        when /^f/ then
          # misn
          # if mission ID xxx is currently active, cause it to fail.
          [:fail_mission, x.delete("f").to_i]
        when /^s/ then
          # misn
          # start mission ID xxx automatically.
          [:start_mission, x.delete("s").to_i]
        when /^g/ then
          # outf
          # grant one of outfit item ID xxx to the player
          [:grant_outfit, x.delete("g").to_i]
        when /^d/ then
          # outf
          # remove (Delete) one of outfit item ID xxx from the player
          [:remove_outfit, x.delete("d").to_i]
        when /^m/ then
          # :syst
          # move the player to system xxx. The player will be put on top of the first stellar in
          # the system, or in the centre of the system if no stellars exist there.
          [:move_to_system, x.delete("m").to_i]
        when /^n/ then
          # :syst
          # move the player to system xxx. The player will remain at the same x/y coordinates,
          # relative to the centre of the system.
          [:move_to_system_pos, x.delete("n").to_i]
        when /^c/ then
          # :ship
          # change the player's ship to ship type (ID) xxx. The player will keep all of his previous
          # outfit items and won't be given any of the default weapons or items that come with
          # ship type xxx.
          [:change_ship, x.delete("c").to_i]
        when /^e/ then
          # :ship
          # change the player's ship to ship type (ID) xxx. The player will keep all of his previous
          # outfit items and will also be given all of the default weapons and items that come
          # with ship type xxx.
          [:change_ship, x.delete("e").to_i]
        when /^h/ then
          # :ship
          # change the player's ship to ship type (ID) xxx. The player will keep all of his previous
          # outfit items and won't be given any of the default weapons or items that come with
          # ship type xxx.
          [:change_ship, x.delete("h").to_i]
        when /^k/ then
          # :rank
          # activate rank ID xxx.
          [:activate_rank, x.delete("k").to_i]
        when /^l/ then
          # :rank
          # deactivate rank ID xxx.
          [:deactivate_rank, x.delete("l").to_i]
        when /^p/ then
          # :snd
          # play sound with ID xxx.
          # NOT used in EVN ?
          [:play_sound, x.delete("p").to_i]
        when /^y/ then
          # :spob
          # destroy stellar ID xxx.
          # NOT used in EVN ?
          [:destroy_stellar, x.delete("y").to_i]
        when /^u/ then
          # :spob
          # regenerate (Un-destroy) stellar ID xxx.
          # NOT used in EVN ?
          [:regenerate_stellar, x.delete("u").to_i]
        when /^q/ then
          # :str
          # make the player immediately leave (absquatulate) whatever stellar he's landed on
          # and return to space, and show a message at the bottom of the screen. The message
          # is randomly selected from the STR# resource with ID xxx, and is parsed for mission
          # text tags (e.g. <PSN> and <PRK> ) but not text-selection tags like those above (e.g.
          # {G "he" "she"} ) (see dësc and mïsn resource descriptions for more examples)
          # io.write("\t"*level)
          # io.write("launch\n")
          [:leave_stellar, x.delete("q").to_i]
        when /^t/ then
          # :str
          # change the name (Title) of the player's ship to a string randomly selected from STR#
          # resource ID xxx. The previous ship name will be substituted for any '*' characters
          # which are encountered in the new string.
          [:change_name, x.delete("t").to_i]
        when /^x/ then
          # :syst
          # make system ID xxx be explored.
          [:explore_system, x.delete("t").to_i]
        else
          [:unknown, x]
        end
      end
    end
  end

  class TestExpression < Expression
    attr_accessor :interpretation

    def initialize(exp)
      @exp = exp.truncated.downcase.strip || ""
      @exp.gsub!(/\s(\d+[^\d])/, ' b\1') # fix some bug with malformed avail_bits
      self.simplify!
    end

    def simplify!
      tt = self.truth_table
      tt.resolve("p0", true)
      tt.resolve("p30", true)
      @exp = tt.formula

      #dbgtt = self.truth_table
      #puts "TTT #{@exp} : #{dbgtt.all_names.length}" if dbgtt.all_names.length > 4

      @tree = ExpressionParser.new(@exp).parse
      @interpretation = final_interpret(interpret(@tree))
    end

    def set_initial_conditions!
      tt = self.truth_table
      10000.times do |i|
        tt.resolve("b#{i}", false)
      end
      tt.resolve("p0", true)
      tt.resolve("p30", true)
      @exp = tt.formula

      @tree = ExpressionParser.new(@exp).parse
      @interpretation = final_interpret(interpret(@tree))
    end

    def truth_table
      local_exp = @exp
      TruthTable.new {local_exp.length > 0 ? eval(local_exp) : true}
    end

    def will_never_happen
      @exp == "false"
    end

    def resolve_to_true
      @exp == "true"
    end

    def resolve_to_false
      @exp == "false"
    end

    def to_s
      @exp
    end

    def inspect
      "\"#{@exp}\" #{@interpretation}"
    end

    def interpret(expression)
      recursive_map(expression) do |x|
        case x
        when /^b/ then
          [:has, x]
        when /^!b/ then
          [:not, x.delete("!")]
        when /^o/ then
          [:has_outfit, x.delete("o").to_i]
        when /^!o/ then
          [:not_outfit, x.delete("!o").to_i]
        when "|"
          :or
        when "&"
          :and
        when "true"
          true
        when "false"
          false
        else
          [:unknown, x]
        end
      end
    end

    def final_interpret(int)
      case int.length
      when 1, 2
        int
      when 3
        [int[1], final_interpret(int[0]), final_interpret(int[2])]
      else
        [:and] + int.select {|i| i != :and}
      end
    end

  end
end