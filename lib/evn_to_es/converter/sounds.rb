# https://github.com/csammis/ResourceForker/blob/master/dissect/Snd.h
require 'nova/raw/extra'
require 'ima4'
module EvnToEs
  module Converter
    class Sounds < Base

      def convert(nova)
        FileUtils.mkdir_p conv.sounds_export_dir
        nova.resources[Nova::Type::SND].each do |id, res|
          tmp_wav = "#{conv.sounds_export_dir}/#{"%05d" % id}.0.wav"
          final_wav = "#{conv.sounds_export_dir}/#{"%05d" % id}.wav"

          if !File.exists?(final_wav)
            snd = Nova::Raw::Snd.read(res[:data])
            snd_header = Nova::Raw::SndHeader.read(res[:data][(snd.commands.first.param2)..-1])

            case snd.format_type
            when 2
              puts "SND TYPE 2 #{id} #{res[:name]} encoding:#{snd_header.encoding} sample_rate:#{snd_header.sample_rate >> 16}" if self.conv.verbose
              File.open(tmp_wav, "wb") do |file|
                file.write('RIFF')
                file.write([snd_header.data_length + 44 - 8].pack('V'))
                file.write('WAVE')
                file.write("fmt ")
                file.write([16].pack('V'))
                file.write([1].pack('v'))
                file.write([1].pack('v'))
                file.write([snd_header.sample_rate >> 16].pack('V'))
                file.write([snd_header.sample_rate >> 16].pack('V'))
                file.write([1].pack('v'))
                file.write([8].pack('v'))
                file.write('data')
                file.write([snd_header.data_length].pack('V'))

                offset = snd.commands.first.param2
                file.write(res[:data][(offset)..-1])
              end
            when 1
              case snd_header.encoding
              when 0
                puts "SND TYPE 1 #{id} #{res[:name]} encoding:#{snd_header.encoding} sample_rate:#{snd_header.sample_rate >> 16}" if self.conv.verbose

                File.open(tmp_wav, "wb") do |file|
                  file.write('RIFF')
                  file.write([snd_header.data_length + 44 - 8].pack('V'))
                  file.write('WAVE')
                  file.write("fmt ")
                  file.write([16].pack('V'))
                  file.write([1].pack('v'))
                  file.write([1].pack('v'))
                  file.write([snd_header.sample_rate >> 16].pack('V'))
                  file.write([snd_header.sample_rate >> 16].pack('V'))
                  file.write([1].pack('v'))
                  file.write([8].pack('v'))
                  file.write('data')
                  file.write([snd_header.data_length].pack('V'))

                  offset = snd.commands.first.param2
                  file.write(res[:data][(offset)..-1])
                end
              when 0xFE
                puts "SND TYPE 1 [compressed] #{id} #{res[:name]} encoding:#{snd_header.encoding} sample_rate:#{snd_header.sample_rate >> 16}" if self.conv.verbose
                snd_data = Nova::Raw::SndEncoded.read(res[:data][(snd.commands.first.param2) + 22..-1])
                if snd_data.compression_format == "ima4\x00".bytes

                  File.open(tmp_wav, "wb") do |file|
                    offset = snd.commands.first.param2 + 22 + 42
                    decoded = Ima4.decode(res[:data][offset..-1], snd_data.frame_count * 34, false)
                    file.write('RIFF')
                    file.write([decoded.length + 44 - 8].pack('V'))
                    file.write('WAVE')
                    file.write("fmt ")
                    file.write([16].pack('V'))
                    file.write([1].pack('v'))
                    file.write([1].pack('v'))
                    file.write([snd_header.sample_rate >> 16].pack('V'))
                    file.write([snd_header.sample_rate >> 16].pack('V'))
                    file.write([1].pack('v'))
                    file.write([16].pack('v'))
                    file.write('data')
                    file.write([decoded.length].pack('V'))
                    file.write(decoded)
                  end
                end
              else
                puts snd
                puts snd_header

                puts "SND #{id} #{res[:name]} unsupported encoding #{snd_header.encoding}" if self.conv.verbose
              end
            else
              puts "SND #{id} #{res[:name]} unsupported format type #{snd.format_type}" if self.conv.verbose
            end

            if File.exists?(tmp_wav)
              system("sox -q #{tmp_wav} -r 44100 -b 16 #{final_wav}")
              FileUtils.rm(tmp_wav)
            end
          else
            puts "SND #{id} #{res[:name]} already converted #{final_wav}" if self.conv.verbose
          end
        end
      end

      def clean(nova)
        FileUtils.rm_rf(conv.sounds_export_dir)
      end

      def priority
        1
      end
    end
  end
end
