module EvnToEs
  module Converter
    class Outfits < Base
      def convert(nova)
        File.open(conv.data_export_path("outfits.txt"), 'w') do |file|
          nova.traverse(:outf) do |id, name, outf|
            outf.print_debug if self.conv.verbose #[:mod_type, :mod_val, :availability, :on_purchase, :on_sale])

            unless outf.unsupported
              weap = nil
              cat = nil
              case outf.mod_type
              when Nova::Record::Outf::Weapon
                weap = outf.weap
                cat = nil
                if weap
                  case weap.guidance
                  when Nova::Record::Weap::Unguided, Nova::Record::Weap::Beam, Nova::Record::Weap::PointDefenseBeam
                    cat = "Guns"
                  when Nova::Record::Weap::TurretedBeam, Nova::Record::Weap::TurretedUnguided,
                      Nova::Record::Weap::FrontQuadrantTurret, Nova::Record::Weap::RearQuadrantTurret,
                      Nova::Record::Weap::PointDefenseTurret
                    cat = "Turrets"
                  when Nova::Record::Weap::Homing, Nova::Record::Weap::FreeFallBomb,
                      Nova::Record::Weap::FreeFlightRocket
                    cat = "Secondary Weapons"
                  end
                end
              when Nova::Record::Outf::Ammunition
                cat = "Ammunition"
              when Nova::Record::Outf::AccelerationBooster,
                  Nova::Record::Outf::SpeedIncrease,
                  Nova::Record::Outf::TurnRateChange,
                  Nova::Record::Outf::Afterburner
                cat = "Engines"
              when Nova::Record::Outf::DensityScanner,
                  Nova::Record::Outf::IFF, Nova::Record::Outf::Map
                cat = "Special"
              when Nova::Record::Outf::MoreCargoSpace, Nova::Record::Outf::MoreShieldCapacity, Nova::Record::Outf::FasterShieldRecharge,
                  Nova::Record::Outf::Armour, Nova::Record::Outf::FuelCapacityIncrease, Nova::Record::Outf::FuelScoop,
                  Nova::Record::Outf::JammingType1, Nova::Record::Outf::JammingType2,
                  Nova::Record::Outf::JammingType3, Nova::Record::Outf::JammingType4
                cat = "Systems"
              when Nova::Record::Outf::Marines
                cat = "Hand to Hand"
              end

              cat = "Guns" if outf.flags_match(Nova::Record::Outf::ItemIsFixedGun)
              cat = "Turrets" if outf.flags_match(Nova::Record::Outf::ItemIsTurret)

              unless cat
                puts "OUTFIT ERROR #{id} #{outf.mod_type}/#{outf.mod_val}" if self.conv.verbose
                cat = "Special"
              end

              conf = self.generate_config :outfit, name do
                entry :plural, outf.lc_plural.to_s.truncated
                entry :thumbnail, self.conv.convert_pict(outf.pict_id, "outfit", "-resize 180x")
                entry :category, cat
                entry :mass, 0#outf.mass if outf.mass != 0
                entry "outfit space", -outf.mass if outf.mass != 0

                entry :cost, outf.cost

                outf.mods.each do |mod|
                  if mod.type != Nova::Record::Outf::None
                    entry "cargo space", mod.val if mod.type == Nova::Record::Outf::MoreCargoSpace
                    entry "shields", mod.val if mod.type == Nova::Record::Outf::MoreShieldCapacity
                    # EV: How much to speed up (1000 = one more shield point per frame)
                    # ES: the number of shield points regenerated per frame. It takes 1 energy to regenerate 1 unit of shields,
                    # so if your shields are recharging your ship has less energy available for other things.
                    entry "shield generation", mod.val / 1000.0 if mod.type == Nova::Record::Outf::FasterShieldRecharge
                    entry "hull", mod.val if mod.type == Nova::Record::Outf::Armour
                    entry "thrust", mod.val if mod.type == Nova::Record::Outf::AccelerationBooster
                    entry "drag", -mod.val/10.0 if mod.type == Nova::Record::Outf::SpeedIncrease
                    entry "turn", mod.val * outf.mass if outf.mod_type == Nova::Record::Outf::TurnRateChange
                    # Nova::Record::Outf::EscapePod
                    entry "fuel capacity", mod.val if mod.type == Nova::Record::Outf::FuelCapacityIncrease
                    # Nova::Record::Outf::DensityScanner
                    # Nova::Record::Outf::IFF
                    entry "afterburner thrust", mod.val / 100.0 if mod.type == Nova::Record::Outf::Afterburner
                    entry "map", mod.val * 6 if mod.type == Nova::Record::Outf::Map
                    # Nova::Record::Outf::CloakingDevice
                    # EV: How many frames per 1 unit of fuel generated. Enter a
                    # negative value to perform the same function in 'fuel sucking' mode
                    # ES: fuel produced per frame.
                    entry "fuel generation", (1.0/mod.val).round(2) if mod.type == Nova::Record::Outf::FuelScoop
                    # Nova::Record::Outf::AutoRefueller
                    # Nova::Record::Outf::AutoEject
                    # Nova::Record::Outf::CleanLegalRecord
                    # Nova::Record::Outf::HyperspaceSpeedMod
                    # Nova::Record::Outf::HyperspaceDistMod
                    # Nova::Record::Outf::InterferenceMod
                    entry "capture attack", mod.val.abs / 10.0 if mod.type == Nova::Record::Outf::Marines
                    # Nova::Record::Outf::IncreaseMaximum
                    # Nova::Record::Outf::MurkModifier
                    entry "hull repair rate", mod.val if mod.type == Nova::Record::Outf::FasterArmourRecharge
                    # Nova::Record::Outf::CloakScanner
                    # Nova::Record::Outf::MiningScoop
                    # Nova::Record::Outf::MultiJump
                    entry "radar jamming", mod.val if mod.type == Nova::Record::Outf::JammingType1
                    entry "radar jamming", mod.val if mod.type == Nova::Record::Outf::JammingType2
                    entry "radar jamming", mod.val if mod.type == Nova::Record::Outf::JammingType3
                    entry "radar jamming", mod.val if mod.type == Nova::Record::Outf::JammingType4
                    # Nova::Record::Outf::FastJumping
                    # Nova::Record::Outf::InertialDampener
                    entry "ion resistance", mod.val if mod.type == Nova::Record::Outf::IonDissipater
                    #entry "ion damage", mod.val if mod.type == Nova::Record::Outf::IonAbsorber
                    # Nova::Record::Outf::GravityResistance
                    # Nova::Record::Outf::ResistDeadlyStellars
                    # Nova::Record::Outf::Paint
                    # Nova::Record::Outf::ReinfInhibitor
                    # Nova::Record::Outf::ModifyMaxGuns
                    # Nova::Record::Outf::ModifyMaxTurrets
                    # Nova::Record::Outf::Bomb
                    # Nova::Record::Outf::IFFScrambler
                    # Nova::Record::Outf::RepairSystem
                    # Nova::Record::Outf::NonlethalBomb
                    #

                    if outf.flags_match(Nova::Record::Outf::ItemCantBeSold)
                      entry :unplunderable, 1
                    end

                    if mod.type == Nova::Record::Outf::Weapon
                      weap = mod.record
                      weap.print_debug if self.conv.verbose

                      if [Nova::Record::Weap::TurretedBeam,Nova::Record::Weap::TurretedUnguided,
                          Nova::Record::Weap::FrontQuadrantTurret, Nova::Record::Weap::RearQuadrantTurret,
                      Nova::Record::Weap::PointDefenseTurret].include?(weap.guidance)
                        #entry "turret mounts", -1
                      else
                        #entry "gun ports", -1
                      end

                      if outf.flags_match(Nova::Record::Outf::ItemIsTurret)
                        entry "turret mounts", -1
                      else
                        if outf.flags_match(Nova::Record::Outf::ItemIsFixedGun)
                          entry "gun ports", -1
                        else
                          entry "gun ports", -1
                        end
                      end

                      entry :weapon do
                        if weap.spin
                          entry "sprite", self.conv.convert_rled(weap.spin.sprites_id, 0, "projectile", "-resize 200%")
                        end

                        entry :sound, "#{"%05d" % (weap.sound + 200)}"

                        if weap.ammo_type
                          entry :ammo, weap.weap_outf.uniq_name if weap.guidance != Nova::Record::Weap::CarriedShip

                          entry :homing, 4 if weap.guidance == Nova::Record::Weap::Homing
                          entry :tracking, 1
                        end

                        if weap.explosion
                          if weap.explod_type >= 1000
                            entry "hit effect", weap.explosion.uniq_name
                            entry "hit effect", nova.get(:boom, 128).uniq_name, 5
                          else
                            entry "hit effect", weap.explosion.uniq_name
                          end
                        end

                        if weap.sub_weap and weap.sub_count > 0
                          #entry :submunition, weap.sub_weap.weap_outf.uniq_name, weap.sub_count
                        end

                        entry "reload", weap.reload * 2
                        entry "lifetime", weap.count_ * 2
                        entry "velocity", (weap.speed / 100.0).round if weap.speed > 0
                        entry "shield damage", weap.energy_dmg
                        entry "hull damage", weap.mass_dmg

                        entry "blast radius", weap.blast_radius if weap.blast_radius > 0
                        entry "trigger radius", weap.prox_radius if weap.prox_radius > 0
                        entry "hit force", weap.impact if weap.impact > 0
                        entry "turret turn", 2.0 if cat == "Turrets"

                        entry "turn", weap.guided_turn/10.0 if weap.guided_turn > 0

                        entry "burst count", weap.burst_count if weap.burst_count > 0
                        entry "burst reload", weap.burst_reload if weap.burst_reload > 0

                        entry "ion damage", weap.ionization if weap.ionization > 0

                        entry "anti-missile", weap.mass_dmg*2 if weap.guidance == Nova::Record::Weap::PointDefenseBeam
                        entry "anti-missile", weap.mass_dmg*2 if weap.guidance == Nova::Record::Weap::PointDefenseTurret
                        entry :inaccuracy, weap.inaccuracy / 2
                      end
                    end
                  end
                end

                if outf.desc_id > 0
                  entry :description, EvnToEs::Description.new(nova, outf.desc_id)
                end

              end
              conf.write(file)
            end
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("outfits.txt"))
        FileUtils.rm_rf("#{conv.images_export_dir}/projectile")
        FileUtils.rm_rf("#{conv.images_export_dir}/outfit")
      end

    end
  end
end
