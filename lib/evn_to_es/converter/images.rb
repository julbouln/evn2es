require 'cicn'
module EvnToEs
  module Converter
    class Images < Base
      def convert(nova)
        FileUtils.mkdir_p "#{conv.images_export_dir}/pict"

        nova.resources[Nova::Type::PICT].each do |id, res|
          tmp_pict = "#{conv.images_export_dir}/pict/#{"%05d" % id}.pict"
          final_png = "#{conv.images_export_dir}/pict/#{"%05d" % id}.png"
          if File.exists?(final_png)
            puts "PICT #{id} #{res[:name]} already converted #{final_png}" if self.conv.verbose
          else

            puts "PICT #{id} #{res[:name]}" if self.conv.verbose
            File.open(tmp_pict, "wb") do |file|
              file.write "\0" * 512
              file.write res[:data]
            end

            system("convert #{tmp_pict} png32:#{final_png}")
            FileUtils.rm "#{tmp_pict}"
          end
        end

        nova.resources[Nova::Type::RLED].each do |id, res|
          if Dir.glob("#{conv.images_export_dir}/rled/#{"%04d" % id}*").length > 0
            puts "RLE #{id} #{res[:name]} already converted" if self.conv.verbose
          else
            rle = Nova::Raw::RLEPixelData.read(res[:data])
            puts "RLE #{id} #{res[:name]} size:#{rle.width}x#{rle.height} depth:#{rle.depth} nframes:#{rle.nframes} num_bytes:#{rle.num_bytes}, data encoding: #{res[:data].encoding} length:#{res[:data].length}" if self.conv.verbose
            rlec = Rle.new(rle, res[:data])
            rlec.convert

            FileUtils.mkdir_p "#{conv.images_export_dir}/rled"
            rlec.write("#{conv.images_export_dir}/rled", "%04d" % id)
          end
        end

        if false
          # TODO
          nova.resources[Nova::Type::CICN].each do |id, res|
            puts "CICN #{id} #{res[:name]}"
            Cicn.decode(res[:data])
          end
        end
      end

      def clean(nova)
        FileUtils.rm_rf("#{conv.images_export_dir}/pict")
        FileUtils.rm_rf("#{conv.images_export_dir}/rled")
      end

      def priority
        1
      end
    end
  end
end
