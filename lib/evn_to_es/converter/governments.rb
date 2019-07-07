module EvnToEs
  module Converter
    class Governments < Base

      def self.govt_personalities(govt)
        personalities = []
        if govt.flags_match(Nova::Record::Govt::AlwaysAttackPlayer)
          personalities << :nemesis
          personalities << :unconstrained
        end

        if govt.flags_match(Nova::Record::Govt::Xenophobic)
          personalities << :nemesis
          personalities << :unconstrained
        end

        if govt.flags_match(Nova::Record::Govt::CantHail)
          personalities << :mute
        end

        if govt.flags_match(Nova::Record::Govt::WarshipPlunder)
          personalities << :plunders
        end

        if govt.flags_match(Nova::Record::Govt::WarshipRetreatWhenLowShield)
          personalities << :heroic
        end

        personalities
      end

      def convert(nova)

        File.open(conv.data_export_path("governements.txt"), 'w') do |file|

          # statically referenced in ES
          conf = self.generate_config :government, "Uninhabited" do
            entry :color, 1.0, 1.0, 1.0
          end
          conf.write(file)

          # statically referenced in ES
          conf = self.generate_config :government, "Escort" do
            entry :swizzle, 5
            entry "fine", 0
          end
          conf.write(file)

          nova.traverse(:govt) do |id, name, govt|
            govt.print_debug if self.conv.verbose
            conf = self.generate_config :government, name do
              col = Nova::Color.to_rgb(govt.color)
              # 0 red + yellow markings (republic)
              # 1 red + magenta markings
              # 2 green + yellow (freeholders)
              # 3 green + cyan
              # 4 blue + magenta (syndicate)
              # 5 blue + cyan (merchant)
              # 6 red and black (pirate)
              # 7 red only (cloaked)
              # 8 black only (outline)
              entry :swizzle, 0
              entry :color, (col[0] / 255.0).round(3),
                    (col[1] / 255.0).round(3),
                    (col[2] / 255.0).round(3)
              entry "friendly hail", "#{name} hails"
              entry "hostile hail", "#{name} hails"
              #entry "penalty for" do
              #  entry :disable, govt.disab_penalty
              #  entry :board, govt.board_penalty
              #  entry :destroy, govt.kill_penalty
              #end

              # ennemies of allies
              allies_ennemies = []
              govt.allies_govts.each do |ally|
                allies_ennemies+=ally.enemies_govts.map(&:id)
              end
              allies_ennemies.uniq

              entry "attitude toward" do
                govt.allies_govts.each do |ally|
                  entry ally.uniq_name, 1.0 if ally.id != id and !allies_ennemies.include?(ally.id)
                end
                govt.enemies_govts.each do |enemy|
                  entry enemy.uniq_name, -1.0
                end
              end

              entry "player reputation", govt.initial_rec

              #if govt.flags_match(Nova::Record::Govt::Xenophobic)
              #  puts "GOVT #{id} #{name} XENOPHOBIC"
              #end

              if govt.flags_match(Nova::Record::Govt::WarshipsTakeBribes) ||
                  govt.flags_match(Nova::Record::Govt::FreightersTakeBribes) ||
                  govt.flags_match(Nova::Record::Govt::PlanetsTakeBribes) ||
                  govt.flags_match(Nova::Record::Govt::ShipsTakeLargerBribes)

                if govt.flags_match(Nova::Record::Govt::ShipsTakeLargerBribes)
                  entry :bribe, 0.05
                else
                  entry :bribe, 0.02
                end

              else
                entry :bribe, 0
              end
            end
            conf.write(file)
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("governements.txt"))
      end

    end
  end
end
