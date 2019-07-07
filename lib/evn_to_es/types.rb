require 'truthtable'

module EvnToEs
  module VarSub
    def self.sub(desc, options = {})
      sub_desc = desc

      if options[:stopover_type]==:return_with_stopover
        sub_desc.gsub!(/\<DST\> in the \<DSY\> system/, "<stopovers>")
        sub_desc.gsub!(/\<DST\>/, "<stopovers>")
      else
        sub_desc.gsub!(/\<DST\> in the \<DSY\> system/, "<destination>")
        sub_desc.gsub!(/\<DST\>/, "<planet>")
      end

#      sub_desc.gsub!(/\<DSY\>/, "<stopovers>") # The name of the destination system.
      sub_desc.gsub!(/\<RST\> in the \<RSY\> system/, "<destination>") # The name of the return system.

      sub_desc.gsub!(/\<RSY\>/, "<system>") # The name of the return system.
      sub_desc.gsub!(/\<RST\>/, "<planet>")
      sub_desc.gsub!(/\<CT\>/, "<commodity>")
      sub_desc.gsub!(/\<CQ\> tons/, "<tons>")
      sub_desc.gsub!(/\<CQ\>/, "<tons>")
      sub_desc.gsub!(/\<DL\>/, "<date>")
      sub_desc.gsub!(/\<PAY\>/, "<payment>")
      sub_desc.gsub!(/\<PN\>/, "<first> <last>")
      sub_desc.gsub!(/\<PNN\>/, "<last>")
      sub_desc.gsub!(/\<PSN\>/, "<ship>")

      # sub_desc.gsub!(/\<PST\>/, "ship")
      sub_desc.gsub!(/\<PRK\>/, "captain")
      sub_desc.gsub!(/\<SRK\>/, "captain")
      sub_desc.gsub!(/\<OSN\>/, "<origin>")
      # more

      sub_desc = self.sub_registered(sub_desc)
      sub_desc = self.sub_gender(sub_desc, 1)

      sub_desc
    end

    def self.sub_registered(desc)
      desc.gsub(/\\\"/, "<DQ>").gsub(/\{[Pp]\s*\"([^\"]+)\"\s+\"([^\"]+)\"\}/, '\1').gsub(/<DQ>/, "\\\"")
    end

    def self.sub_gender(desc, m)
      desc.gsub(/\\\"/, "<DQ>").gsub(/\{[Gg]\s*\"([^\"]+)\"\s+\"([^\"]+)\"\}/, m == 1 ? '\2' : '\1').gsub(/<DQ>/, "\\\"")
    end

    def self.sub_has_bit(desc, v)
      desc.gsub(/\\\"/, "<DQ>").gsub(/\{[Bb]\d+\s*\"([^\"]*)\"\s*\"([^\"]*)\"\}/, v ? '\1' : '\2').gsub(/<DQ>/, "\\\"")
    end

    def self.branch(desc)
      if desc =~ /\{[Bb]\d+/
        desc.gsub(/.*\{([Bb]\d+)[^\d].*/, '\1').downcase
      end
    end

  end


  class DescriptionLine
    def endline
      true
    end

    def initialize(desc)
      @desc = desc
    end

    def write(io, level=0)
      io.write "`#{@desc}`\n"
    end
  end

  class ConversationLine
    def endline
      true
    end

    def initialize(desc)
      @desc = desc
    end

    def write(io, level=0)
      io.write "\t" * (level)
      io.write "`#{@desc}`\n"
    end
  end

  class Text
    def endline
      true
    end

    def initialize(files, desc_id, options = {})
      @files = files
      @desc = files.get_desc(desc_id)
      @options = options
      unless @desc
        puts "WARN desc #{desc_id} NOT FOUND"
        @desc = ""
      end
    end

    def write(io, level = 0)
    end
  end

  class Conversation < Text
    def _write(io, txt, level = 0)
      txts = txt.split(/\r/)
      txts.delete_if {|t| t.strip.length == 0}
      txts.each do |txt|
        io.write "\t" * (level)
        io.write "`#{txt}`\n"
      end
    end

    def write(io, level = 0)
      txt = VarSub.sub(@desc, @options)
      if true
        bit = VarSub.branch(txt)
        if bit
          branch1 = VarSub.sub_has_bit(txt, true)
          branch2 = VarSub.sub_has_bit(txt, false)
          #puts "BRANCH BRANCH1 #{branch1}"
          #puts "BRANCH BRANCH2 #{branch2}"

          idx = txt.index(bit)
          io.write "\t" * level
          io.write "branch \"bit_set#{idx}\" \"bit_clear#{idx}\"\n"
          io.write "\t" * (level + 1)
          io.write "has \"#{bit}\"\n"
          io.write "\t" * level
          io.write "label \"bit_set#{idx}\"\n"
          self._write(io, branch1, level + 1)
          io.write "\t" * level
          io.write "label \"bit_clear#{idx}\"\n"
          self._write(io, branch2, level + 1)

        else
          self._write(io, txt, level)
        end
      end

      #self._write(io, txt, level)
    end
  end

  class Description < Text
    def write(io, level = 0)
      txt = VarSub.sub(@desc, @options).gsub(/\r/, " ")
      io.write "`#{txt}`\n"
    end
  end

  class MultiLineDescription < Text
    def write(io, level = 0)
      txts = VarSub.sub(@desc, @options).split(/\r/)
      txts.delete_if {|t| t.strip.length == 0}
      io.write "`#{txts[0]}`\n"
      if txts.length > 1
        txts[1..-1].each do |txt|
          io.write "\t" * (level + 1)
          io.write "`#{txt}`\n"
        end
      end
    end
  end

  class TestExpression
    def endline
      true
    end

    def will_never_happen
      @exp.will_never_happen
    end

    def initially_available
      @exp.initially_available
    end

    def initialize(exp)
      @exp = Nova::TestExpression.new(exp)
    end

    def rec_write(io, int, level = 0)
      if int.is_a? Array
        case int[0]
        when :and
          io.write "\t" * level
          io.write "and\n"
          int[1..-1].each do |sint|
            self.rec_write(io, sint, level + 1)
          end
        when :or
          io.write "\t" * level
          io.write "or\n"
          int[1..-1].each do |sint|
            self.rec_write(io, sint, level + 1)
          end
        when :has
          io.write "\t" * level
          io.write "has \"#{int[1]}\"\n"
        when :not
          io.write "\t" * level
          io.write "not \"#{int[1]}\"\n"
        when :has_outfit
        when :not_outfit
        else
          self.rec_write(io, int[0], level)
        end
      end
    end

    def write(io, level = 0)
      if !@exp.will_never_happen and @exp.to_s.length > 0
        self.rec_write(io, @exp.interpretation, level)
      end
    end

  end

  class SetExpression
    def endline
      true
    end

    def initialize(exp, files)
      @files = files
      @exp = Nova::SetExpression.new(exp, files)
    end

    def write(io, level = 0)
      @exp.interpretation.each do |int|
        case int[0]
        when :unknown
        when :random
        when :set_bit
          io.write("\t" * level)
          io.write("set \"#{int[1]}\"\n")
        when :clear_bit
          io.write("\t" * level)
          io.write("clear \"#{int[1]}\"\n")
        when :toggle_bit
          # UNSUPPORTED
        when :abort_mission
          # TODO USE "defer" token in conversation ?
        when :fail_mission
          io.write("\t" * level)
          misn = @files.get(:misn, int[1])
          io.write("fail \"#{misn.uniq_name}\"\n")
        when :start_mission
          # TODO set a special variable which will be required in the to offer of the other mission ?
        when :grant_outfit
          outf = @files.get(:outf, int[1])
          unless outf.unsupported
            io.write("\t" * level)
            io.write("outfit \"#{outf.uniq_name}\" +1\n")
          end
        when :remove_outfit
          outf = @files.get(:outf, int[1])
          unless outf.unsupported
            io.write("\t" * level)
            io.write("outfit \"#{outf.uniq_name}\" -1\n")
          end
        when :move_to_system
          # UNSUPPORTED BY ES
        when :change_ship
          # UNSUPPORTED BY ES
        when :change_name
          # UNSUPPORTED BY ES
        when :activate_rank
          # UNSUPPORTED BY ES
        when :deactivate_rank
          # UNSUPPORTED BY ES
        when :leave_stellar
          # SUPPORTED IN CONVERSATION with "launch" token
        when :explore_system
          # SUPPORTED BY EVENT
        end
      end
    end

  end


  class SetExpressionEvent
    def endline
      true
    end

    def initialize(exp, files)
      @files = files
      @exp = Nova::SetExpression.new(exp, files)
    end

    def write(io, level = 0)
      @exp.interpretation.each do |int|
        case int[0]
        when :unknown
        when :random
        when :set_bit
          io.write("\t" * level)
          io.write("set \"#{int[1]}\"\n")
        when :clear_bit
          io.write("\t" * level)
          io.write("clear \"#{int[1]}\"\n")
        when :toggle_bit
          # UNSUPPORTED
        when :abort_mission
          # ?
        when :fail_mission
          # SUPPORTED IN MISSION
        when :start_mission
          # TODO set a special variable which will be required in the to offer of the other mission ?
        when :grant_outfit
          # SUPPORTED IN MISSION
        when :remove_outfit
          # SUPPORTED IN MISSION
        when :move_to_system
          # UNSUPPORTED BY ES
        when :change_ship
          # UNSUPPORTED BY ES
        when :change_name
          # UNSUPPORTED BY ES
        when :activate_rank
          # UNSUPPORTED BY ES
        when :deactivate_rank
          # UNSUPPORTED BY ES
        when :leave_stellar
          # ?
        when :explore_system
          syst = @files.get(:syst, int[1])
          io.write("\t" * level)
          io.write("visit \"#{syst.uniq_name}\"\n")
        end
      end
    end

  end

end
