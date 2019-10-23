module EvnToEs
  module Converter
    class Ships < Base
      def convert(nova)
        File.open(conv.data_export_path("ships.txt"), 'w') do |file|
          nova.traverse(:ship) do |id, name, ship|
            ship.print_debug if self.conv.verbose #([:mass, :accel, :maneuver, :speed, :free_mass])

            pict_id = nil
            ship_name = nova.raw_name_from_id(:ship, id)
            if nova.ids_from_name(:ship, ship_name)
              pict_id = nova.ids_from_name(:ship, ship_name).first - 128 + 5000
            end
            desc_id = nil
            if nova.ids_from_name(:ship, ship_name)
              desc_id = nova.ids_from_name(:ship, ship_name).first - 128 + 13000
            end

            # special outfit for each ship
            conf = self.generate_config :outfit, name do
              entry :category, "Special"
              entry :mass, 0
              entry :unplunderable, 1
            end
            conf.write(file)

            conf = self.generate_config :ship, name do
              #puts "SHIP \"#{name}\" \"#{ship.long_name.to_s}\" \"#{ship.sub_title}\""
              #entry :name, ship.comm_name.to_s
              if ship.shan
                if self.conv.patched
                  entry :sprite, self.conv.convert_rled_frames(ship.shan.base_image_id, 0, ship.shan.frames_per - 1, "ship", "-resize 200%") do
                    entry "pre rendered rotation", ship.shan.frames_per.to_i
                  end
                else
                  entry :sprite, conv.convert_rled(ship.shan.base_image_id, ship.shan.frames_per / 2, "ship", "-rotate \"180\" -resize 200%")
                end
              else
                puts "ERROR #{ship.id} #{ship.name} no shan"
              end
              if pict_id
                entry :thumbnail, "pict/#{"%05d" % (pict_id)}"
              end

              free_mass = ship.free_mass.to_i
              free_mass += ship.weaps.compact.inject(0) do |s, w|
                if w.weap_outf
                  s += w.weap_outf.mass.to_i * w.count
                else
                  s += 0
                end
              end
              free_mass += ship.ammos.compact.inject(0) do |s, w|
                if w.ammo_outf
                  s += w.ammo_outf.mass.to_i * w.count
                else
                  s += 0
                end
              end

              free_mass += ship.outfs.compact.inject(0) do |s, o|
                s += o.mass.to_i * o.count
              end

              entry :attributes do
                required_licenses = []
                ship.require.each_with_index do |b, i|
                  if b and nova.licenses[i]
                    required_licenses << nova.licenses[i]
                  end
                end

                if required_licenses.length > 0
                  entry :licenses do
                    required_licenses.each do |l|
                      entry l
                    end
                  end
                end

                category = "Light Freighter"

                if ship.strength.to_f / ship.mass < 0.25
                  if ship.mass > 500
                    category = "Heavy Freighter"
                  else
                    category = "Light Freighter"
                  end
                else
                  category = "Interceptor"
                  if ship.mass > 75
                    category = "Light Warship"
                  end
                  if ship.mass > 200
                    category = "Medium Warship"
                  end
                  if ship.mass > 500
                    category = "Heavy Warship"
                  end
                end

                if nova.ids_from_name(:outf, ship.name)
                  category = "Fighter"
                end

                entry :category, category

                entry :cost, ship.cost
                entry :shields, ship.shield
                entry :hull, ship.armor
                entry "required crew", ship.crew
                if ship.crew == 0
                  entry :automaton, 1
                end

                entry :bunks, ship.crew + ship.max_tur

                # ES Heavy Shuttle
                # "mass" 110
                # "thrust" 11.5
                # "turn" 307
                # "drag" 2.1
                # ACCEL = 11.5/110 ~= 0.1 (/frame)
                # TURN RATE = 307/110 ~= 2.8 (°/frame)
                # MAX SPEED = 11.5/2.1 ~= 5.5 (/frame)

                # EV Heavy Shuttle
                # mass: 25
                # accel: 485
                # speed: 390
                # maneuver: 39

                # max_speed = thrust / drag
                # drag * max_speed = thrust
                # drag = trust / max_speed

                # ES: the mass of the ship's chassis, without any outfits or cargo. The higher the mass,
                # the more thrust is needed in order to turn or accelerate at a certain rate.
                # EV: Mass: The mass of the ship, in tons. This doesn't affect acceleration or speed at
                # all, but it does affect travel time in hyperspace and the display on the
                # density scanner. Also, the blast radius and impact strength when the ship
                # explodes is proportional to its mass.
                entry :mass, ship.mass.to_i
                # FIXME: using total mass create a bug in ES at hyperdrive
                mass = ship.mass #+ free_mass + ship.holds
                # ES: your ship's turn rate is (turn / mass) degrees per frame.
                # EV: Maneuver: Turn rate. 10 ~= 30°/sec.
                # maneuver = turn / mass
                # turn = maneuver * mass
                turn = (ship.maneuver.to_f * mass) / 20.0
                entry :turn, turn.round(1)

                # ES: your ship's acceleration per frame equals thrust / mass.
                # EV: Accel: Acceleration magnitude. 300 is considered an average value.
                # accel == thrust / mass
                # thrust == accel * mass
                thrust = (ship.accel.to_f * mass) / 2000.0
                entry :thrust, thrust.round(1)
                # ES: the maximum speed of the ship will be equal to "thrust" / "drag".
                # EV: Speed: Top speed. 300 is also an average value here.
                drag = (thrust / ship.speed.to_f) * 100.0
                entry :drag, drag.round(1)
                #puts "SHIP #{id} #{name} mass:#{ship.mass.to_i} free_mass:#{free_mass} holds:#{ship.holds} thrust:#{thrust} turn:#{turn} drag:#{drag} turn/mass #{turn / ship.mass.to_i}"


                entry "energy generation", 1.0
                entry "heat dissipation", 1.0
                entry "fuel capacity", ship.fuel
                entry "cargo space", ship.holds
                entry "outfit space", free_mass
                entry "weapon capacity", free_mass
                entry "engine capacity", free_mass
                entry "hyperdrive", 1
                entry "jump speed", 0.2
                entry "jump fuel", 100

                if ship.shan
                  if ship.shan.glow_image_id > -1
                    if self.conv.patched
                      entry "flare sprite", conv.convert_rled_frames(ship.shan.glow_image_id, 0, ship.shan.frames_per - 1, "flare", "-resize 200%") do
                        entry "pre rendered rotation", ship.shan.frames_per.to_i
                      end
                    else
                      entry "flare sprite", conv.convert_rled(ship.shan.glow_image_id, ship.shan.frames_per / 2, "flare", "-rotate \"180\" -resize 200%")
                    end

                    entry "flare sound", "00602"
                  end
                else
                  puts "ERROR #{ship.id} #{ship.name} no shan"
                end

                entry :weapon do
                  entry "blast radius", ((ship.shield + ship.armor) * 0.01 * 5).round
                  entry "shield damage", ((ship.shield + ship.armor) * 0.1 * 5).round
                  entry "hull damage", ((ship.shield + ship.armor) * 0.05 * 5).round
                  entry "hit force", ((ship.shield + ship.armor) * 0.15 * 5).round
                end

              end

              entry :outfits do
                entry name

                ship.weaps.compact.each do |weap|
                  if weap.weap_outf
                    if !weap.unsupported and weap.count > 0
                      entry weap.weap_outf.uniq_name, weap.count
                    end
                  end
                end

                ship.ammos.compact.each do |weap|
                  if weap.ammo_outf
                    if !weap.unsupported and weap.count > 0
                      entry weap.ammo_outf.uniq_name, weap.count
                    end
                  end
                end

                ship.outfs.compact.each do |outf|
                  if outf.count > 0
                    if !outf.unsupported
                      entry outf.uniq_name, outf.count
                    end
                  end
                end
              end

              ship.weaps.compact.each do |weap|
                if weap.guidance == Nova::Record::Weap::CarriedShip
                  entry :fighter, 0, 0
                end
              end

              entry :engine, 0, 0

              if ship.shan
                ship.shan.print_debug if self.conv.verbose

                ship.max_gun.times do |i|
                  entry :gun, ship.shan.gun_pos_x[i] * 2, ship.shan.gun_pos_y[i] * 2
                end

                ship.max_tur.times do |i|
                  entry :turret, ship.shan.turret_pos_x[i] * 2, ship.shan.turret_pos_y[i] * 2
                end
              else
                puts "ERROR #{ship.id} #{ship.name} no shan"
              end

              if ship.explosion1
                entry :explode, ship.explosion1.uniq_name, ship.death_delay / 5
              end

              if ship.explosion2
                entry "final explode", ship.explosion2.uniq_name
              end

              if desc_id
                entry :description, EvnToEs::Description.new(nova, desc_id, initial: true)
              end

            end
            conf.write(file)
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("ships.txt"))
        FileUtils.rm_rf("#{conv.images_export_dir}/ship")
        FileUtils.rm_rf("#{conv.images_export_dir}/flare")
      end

    end
  end
end
