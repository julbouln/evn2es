module EvnToEs
  module Converter
    # TODO: not used yet
    class Asteroids < Base
      def convert(nova)

        File.open(conv.data_export_path("asteroids.txt"), 'w') do |file|
          standard = nova.get(:str, 4000).strings[0..5].map(&:string).map(&:to_s)
          yielded = {}
          nova.traverse(:roid) do |id, name, roid|
            yid = roid.yield_type
            if yid > -1
              yname = nil
              if yid < 6
                yname = standard[yid]
              else
                junk = nova.get(:junk, yid - 1000 + 128)
                yname = junk.uniq_name
              end

              yielded[yid] = yname
            end

          end

          yielded.each do |yid, yname|
            conf = self.generate_config :outfit, yname do
              entry :category, "Special"
              entry :cost, 1000
              entry "mass", 1
              entry "installable", -1
            end
            conf.write(file)

          end

          nova.traverse(:roid) do |id, name, roid|
            roid.print_debug if self.conv.verbose

            if roid.yield_type > -1
            conf = self.generate_config :minable, roid.uniq_name do
              entry :hull, roid.strength
              entry :payload, yielded[roid.yield_type], roid.yield_qty
            end
            conf.write(file)
            end


          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("asteroids.txt"))
      end

    end
  end
end
