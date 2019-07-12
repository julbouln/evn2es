require 'resourcefork'
require 'treetop'
require 'truthtable'

require 'nova'
require 'nova/record'
require 'nova/expression'

module Nova
  module Type
    SND = "snd ".bytes
    PICT = "PICT".bytes
    STR = "STR#".bytes
    CICN = "cicn".bytes
    PPAT = "ppat".bytes

    RLE8 = "rlë8".bytes
    RLED = "rlëD".bytes
    SHAN = "shän".bytes
    VERS = "vers".bytes
    COLR = "cölr".bytes
    SPIN = "spïn".bytes
    INTF = "ïntf".bytes
    BOOM = "bööm".bytes
    DESC = "dësc".bytes
    FLET = "flët".bytes
    ROID = "röid".bytes
    NEBU = "nëbu".bytes
    CRON = "crön".bytes
    CHAR = "chär".bytes
    CSUM = "csüm".bytes
    GOVT = "gövt".bytes
    JUNK = "jünk".bytes
    MISN = "mïsn".bytes
    SHIP = "shïp".bytes
    DUDE = "düde".bytes
    RANK = "ränk".bytes
    SPOB = "spöb".bytes
    SYST = "sÿst".bytes
    OOPS = "öops".bytes
    OUTF = "oütf".bytes
    PERS = "përs".bytes
    WEAP = "wëap".bytes
  end

  module Color
    def self.to_rgb(color)
      col = color.to_hex
      [col[2..3].to_i(16), col[4..5].to_i(16), col[6..7].to_i(16)]
    end
  end

  class Files
    extend Memoist
    attr_accessor :types, :id_to_name, :name_to_id, :resources

    def initialize
      @types = Set.new
      @resources = {}
      @ids_to_names = {}
      @names_to_ids = {}
      @name_variants = {}

      @mapping = {}
    end

    def load(files)
      files.each do |f|
        #puts "Load #{f}"
        rf = ResourceFork.new(File.open(f))
        rf.resources.each do |r|
          name = r.name || "Unnamed"
          type = r.type.bytes
          @types << r.type

          @ids_to_names[type] ||= {}
          @ids_to_names[type][r.id] = name

          @names_to_ids[type] ||= {}
          @names_to_ids[type][name.sub(/\;.*/, "")] ||= []
          @names_to_ids[type][name.sub(/\;.*/, "")] << r.id

          @name_variants[type] ||= {}
          @name_variants[type][name] ||= []
          @name_variants[type][name] << r.id

          @resources[type] ||= {}
          @resources[type][r.id] = {:name => name, :data => r.data}
        end
      end

      self.mappers
    end

    def debug
      puts "---"
      puts @types.to_a.join(", ")
      puts @resources.length
    end

    def name_suffix(sym, name, id)
      ids = self.ids_from_name(sym, name)
      if ids
        if ids.length > 1
          type = self.type_from_sym(sym)
          full_name = self.raw_name_from_id(sym, id)
          names = full_name.split(";")
          if names.length > 1
            idx = @name_variants[type][full_name].index(id)
            if idx > 0
              " (#{names.last}) ##{idx}"
            else
              " (#{names.last})"
            end
          else
            idx = @name_variants[type][full_name].index(id)
            if idx > 0
              " ##{idx}"
            else
              ""
            end
          end
        else
          full_name = self.raw_name_from_id(sym, id)
          names = full_name.split(";")
          if names.length > 1
            " (#{names.last})"
          else
            ""
          end
        end
      else
        #puts "NO #{type.pack("CCCC")} #{name}/#{id} FOUND"
        "[ERROR #{id}]"
      end
    end

    def ids_from_name(sym, name)
      type = self.type_from_sym(sym)
      if @names_to_ids[type]
        @names_to_ids[type][name.sub(/\;.*/, "")]
      end
    end

    def raw_name_from_id(sym, id)
      type = self.type_from_sym(sym)
      @ids_to_names[type][id]
    end

    def name_from_id(sym, id)
      name = self.raw_name_from_id(sym, id)
      "#{name.sub(/\;.*/, "")}#{self.name_suffix(sym, name, id)}"
    end


    def get(sym, id)
      res = resources[self.type_from_sym(sym)][id]
      if res
        raw = self.raw_from_sym(sym).read(res[:data])
        if raw
          self.record_from_sym(sym).new(id, res[:name], raw, self)
        end
      end
    end

    def traverse(sym, &block)
      resources[self.type_from_sym(sym)].each do |id, res|
        raw = self.raw_from_sym(sym).read(res[:data])
        rec = self.record_from_sym(sym).new(id, res[:name], raw, self)
        block.call id, rec.uniq_name, rec
      end
    end

    def raw_from_sym(sym)
      Object.const_get "Nova::Raw::#{sym.to_s.capitalize}"
    end

    def record_from_sym(sym)
      Object.const_get "Nova::Record::#{sym.to_s.capitalize}"
    end

    def type_from_sym(sym)
      Object.const_get "Nova::Type::#{sym.to_s.upcase}"
    end

    ###

    def get_desc(id)
      if @resources[Nova::Type::DESC][id]
        Iconv.conv('UTF8', 'MAC', @resources[Nova::Type::DESC][id][:data].truncated).strip
      end
    end

    def get_str(id)
      if @resources[Nova::Type::STR][id]
        Nova::Raw::Str.read(@resources[Nova::Type::STR][id][:data])[:strings].map {|str| Iconv.conv('UTF8', 'MAC', str[:string].to_s.truncated.strip)}
      end
    end

    def governments_classes
      govt_classes = {}
      self.traverse(:govt) do |id, name, govt|
        govt.classes.each do |cl|
          if cl > -1
            govt_classes[cl] ||= []
            govt_classes[cl] << self.get(:govt, id)
            govt_classes[cl].uniq!
          end
        end
      end
      govt_classes
    end

    memoize :governments_classes

    def initial_flets
      flets = []
      self.traverse(:flet) do |fid, fname, flet|
        if flet.initially_available
          flets << flet
        end
      end
      flets
    end

    memoize :initial_flets

    # extra set
    def set_tree
      tree = {}
      [:ship, :outf, :junk, :nebu, :syst, :spob, :flet, :oops, :pers].each do |type|
        self.traverse(type) do |id, name, obj|
          obj.set_expressions.each do |key, exp|
            tree[exp.to_s] ||= []
            tree[exp.to_s] << {type: type, set: key, id: id, name: name}
          end
        end
      end
      tree.delete("")
      tree
    end

    memoize :set_tree

    # extra test
    def test_tree
      tree = {}
      [:ship, :outf, :junk, :nebu, :syst, :spob, :flet, :oops, :pers].each do |type|
        self.traverse(type) do |id, name, obj|
          obj.test_expressions.each do |key, exp|
            tree[exp.to_s] ||= []
            tree[exp.to_s] << {type: type, test: key, id: id, name: name}
          end
        end
      end
      tree.delete("true")
      tree.delete("false")
      tree
    end

    attr_accessor :weaps_to_outfits, :ammos_to_outfits

    def weap_outfit_mapper
      @weaps_to_outfits = {}
      @ammos_to_outfits = {}
      self.traverse(:outf) do |id, name, outf|
        outf.mods.each do |mod|
          unless weaps_to_outfits[mod.val]
            @weaps_to_outfits[mod.val] = outf if mod.type == Nova::Record::Outf::Weapon
          end
          unless ammos_to_outfits[mod.val]
            @ammos_to_outfits[mod.val] = outf if mod.type == Nova::Record::Outf::Ammunition
          end
        end
      end
    end

    def licenses
      lic = {}
      self.traverse(:outf) do |id, name, outf|
        if name =~ /License/
          if outf.contribute.select {|b| b}.length == 1
            #puts "OUTF #{id} #{name} : contribute:#{outf.contribute.reverse.map {|b| b ? "1" : "0"}.join("")}"
            #puts "OUTF #{id} #{name} : require:#{outf.require.reverse.map {|b| b ? "1" : "0"}.join("")}"
            lic[outf.contribute.index(true)] = outf.uniq_name.gsub(/\sLicense/, "")
          else
            puts "WARN complex license #{id} #{name} : availability:#{outf.availability} contribute:#{outf.contribute.reverse.map {|b| b ? "1" : "0"}.join("")}"
          end
        end
      end
      lic
    end

    memoize :licenses

    def mappers
      self.weap_outfit_mapper
    end

    attr_accessor :mapping

  end
end