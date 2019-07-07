module EvnToEs
  module Converter
    class Effects < Base
      def convert(nova)
        # constant
        self.conv.copy_sound(129, "hyperdrive")
        self.conv.copy_sound(151, "fail")
        self.conv.copy_sound(370, "alarm")
        self.conv.copy_sound(390, "landing")

        File.open(conv.data_export_path("effects.txt"), 'w') do |file|
          nova.traverse(:boom) do |id, name, boom|
            boom.print_debug if self.conv.verbose

            conf = self.generate_config :effect, name do
              entry :sprite, self.conv.convert_rled_frames(boom.spin.sprites_id, 0, (boom.spin.nx * boom.spin.ny) - 1, "effect", "-resize 200%") do
                entry "no repeat"
                entry "frame rate", (15 * boom.frame_advance / 100.0).round
              end
              entry :sound, "#{"%05d" % (boom.sound_index + 300)}"
              entry :lifetime, 15
              entry "velocity scale", 0
            end
            conf.write(file)
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("effects.txt"))
        FileUtils.rm_rf("#{conv.images_export_dir}/effect")
      end

    end
  end
end
