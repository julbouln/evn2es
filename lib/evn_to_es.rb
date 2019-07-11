require 'nova'
require 'evn_to_es/converter'

module EvnToEs
  class Convert
    extend Memoist
    attr_accessor :files, :export_dir, :verbose, :patched, :cheat

    def images_export_dir
      "#{self.export_dir}/images"
    end

    def sounds_export_dir
      "#{self.export_dir}/sounds"
    end

    def data_export_dir
      "#{self.export_dir}/data"
    end

    def data_export_path(file)
      "#{self.data_export_dir}/#{file}"
    end

    def convert_rled(id, frame, destdir, opt = "")
      img_dir = self.images_export_dir
      FileUtils.mkdir_p "#{img_dir}/#{destdir}"
      subdir = "rled"
      srcfile = "#{img_dir}/#{subdir}/#{"%04d" % (id)}_#{"%03d" % frame}.png"
      dstkey = "#{destdir}/#{"%04d" % (id)}"
      dstfile = "#{img_dir}/#{destdir}/#{"%04d" % (id)}.png"
      if File.exists?(srcfile)
        unless File.exists?(dstfile)
          system("convert #{opt} #{srcfile} #{dstfile}")
        end
      else
        puts "ERROR convert_rled cannot convert #{dstfile} : #{srcfile} not found" if @verbose
      end
      dstkey
    end

    def convert_rled_frames(id, frame_start, frame_end, destdir, opt = "", dest_prefix = nil)
      img_dir = self.images_export_dir
      FileUtils.mkdir_p "#{img_dir}/#{destdir}"
      subdir = "rled"

      dstkey = "#{destdir}/#{"%04d" % (id)}"
      i = 0
      (frame_start..frame_end).each do |frame|
        srcfile = "#{img_dir}/#{subdir}/#{"%04d" % (id)}_#{"%03d" % frame}.png"
        dstfile = "#{img_dir}/#{destdir}/#{"%04d" % (id)}-#{i}.png"
        if dest_prefix
          dstfile = "#{img_dir}/#{destdir}/#{dest_prefix}-#{i}.png"
        end
        if File.exists?(srcfile)
          unless File.exists?(dstfile)
            system("convert #{opt} #{srcfile} #{dstfile}")
          end
        else
          puts "ERROR convert_rled_frames cannot convert #{dstfile} : #{srcfile} not found" if @verbose
        end
        i = i + 1
      end
      dstkey
    end

    def convert_pict(id, destdir, opt = "")
      img_dir = self.images_export_dir
      FileUtils.mkdir_p "#{img_dir}/#{destdir}"
      subdir = "pict"
      srcfile = "#{img_dir}/#{subdir}/#{"%05d" % (id)}.png"
      dstkey = "#{destdir}/#{"%05d" % (id)}"
      dstfile = "#{img_dir}/#{destdir}/#{"%05d" % (id)}.png"
      if File.exists?(srcfile)
        unless File.exists?(dstfile)
          system("convert #{opt} #{srcfile} #{dstfile}")
        end
      else
        puts "ERROR convert_pict cannot convert #{dstfile} : #{srcfile} not found" if @verbose
      end
      dstkey
    end

    def copy_sound(id, dest)
      src_file = "#{self.sounds_export_dir}/#{"%05d" % (id)}.wav"
      dst_file = "#{self.sounds_export_dir}/#{dest}.wav"
      FileUtils.cp(src_file, dst_file) if File.exist?(src_file)
    end

    def convert_sound(id, destdir)
      snd_dir = self.sounds_export_dir
      src_file = "#{snd_dir}/#{"%05d" % (id)}.wav"
      dst_file = "#{snd_dir}/#{destdir}/#{"%05d" % (id)}.mp3"
      FileUtils.mkdir_p "#{snd_dir}/#{destdir}"
      if File.exists?(src_file)
        unless File.exists?(dst_file)
          system("lame --quiet #{src_file} #{dst_file}")
        end
      end
      dst_file
    end

    def get_shipyards
      shipyards = {}
      @files.traverse(:ship) do |id, name, ship|
        shipyards["Tech level #{ship.tech_level}"] ||= []
        if ship.buy_random.to_i != 0 and ship.initially_available
          shipyards["Tech level #{ship.tech_level}"] << name
        end
      end
      shipyards
    end

    memoize :get_shipyards

    def get_outfitters
      outfitters = {}
      @files.traverse(:outf) do |id, name, outf|
        # outf.print_debug
        outfitters["Tech level #{outf.tech_level}"] ||= []
        if !outf.unsupported and outf.buy_random.to_i != 0 and outf.initially_available
          #puts "OUTF #{name} available : #{outf.availability}/#{outf.initially_available}"
          outfitters["Tech level #{outf.tech_level}"] << name
        end
      end
      outfitters
    end

    memoize :get_outfitters

    def initialize(exp_dir = "evn", verbose = false, patched = false)
      @export_dir = exp_dir
      @verbose = verbose
      @patched = patched
      @cheat = true
    end

    def convert(files, arg = nil)
      FileUtils.cp_r("required", @export_dir) unless File.exists?(@export_dir)

      @files = Nova::Files.new
      @files.load(files)

      conv_objects = Converter.constants.map do |klass_sym|
        if !arg or arg == klass_sym.to_s
          klass = Converter.const_get(klass_sym)
          klass.new(self)
        end
      end

      conv_objects.compact!

      conv_objects.sort {|a, b| a.priority <=> b.priority}.each do |conv|
        if conv
          puts "Convert #{conv.class.name}" if @verbose
          conv.convert(@files)
        end
      end

      @files.debug if @verbose
    end

    def clean(files, arg = nil)
      @files = Nova::Files.new
      @files.load(files)

      conv_objects = Converter.constants.map do |klass_sym|
        if !arg or arg == klass_sym.to_s
          klass = Converter.const_get(klass_sym)
          klass.new(self)
        end
      end

      conv_objects.compact!

      conv_objects.sort {|a, b| a.priority <=> b.priority}.each do |conv|
        if conv
          puts "Clean #{conv.class.name}" if @verbose
          conv.clean(@files)
        end
      end
    end

  end
end

require 'evn_to_es/types'