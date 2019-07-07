module EvnToEs
  module Converter
    class Planets < Base

      def convert(nova)
        shipyards = self.conv.get_shipyards
        outfitters = self.conv.get_outfitters

        File.open(conv.data_export_path("planets.txt"), 'w') do |file|
          nova.traverse(:spob) do |id, name, spob|
            unless spob.unsupported
              spob.print_debug if self.conv.verbose
              conf = self.generate_config :planet, name do
                attributes = []
                if spob.flags_match(Nova::Record::Spob::StellarIsUninhabited)
                  attributes << "uninhabited"
                end
                if spob.flags_match(Nova::Record::Spob::StellarIsStation)
                  attributes << "station"
                end

                if false
                  if spob.govt
                    spob.govt.classes.each do |cl|
                      if cl > -1
                        attributes << "gov class #{cl}"
                      end
                    end
                  end
                end

                entry :attributes, *attributes if attributes.length > 0
                if spob.cust_pic_id > 127
                  entry :landscape, self.conv.convert_pict(spob.cust_pic_id, "land", "-resize 720x360\!")
                else
                  entry :landscape, self.conv.convert_pict((spob.spob_type > 58 ? spob.spob_type - 1 : spob.spob_type) + 10000, "land", "-resize 720x360\!")
                end

                if spob.cust_snd_id > -1
                  entry :music, self.conv.convert_sound(spob.cust_snd_id, "ambient")
                end

                if spob.desc_id > 0
                  entry :description, EvnToEs::Description.new(nova, spob.desc_id)
                end
                if spob.flags_match(Nova::Record::Spob::HasBar)
                  if spob.bar_desc_id > 0
                    entry :spaceport, EvnToEs::Description.new(nova, spob.bar_desc_id)
                  else
                    entry :spaceport, EvnToEs::DescriptionLine.new("No spaceport text")
                  end
                end

                if spob.govt
                  entry :government, spob.govt.uniq_name
                else
                  entry :government, "Uninhabited"
                end

                if spob.flags_match(Nova::Record::Spob::CanOutfit)
                  spob.tech_level.times do |tl|
                    entry :outfitter, "Tech level #{tl}" if outfitters["Tech level #{tl}"]
                  end
                  entry :outfitter, "Tech level #{spob.special_tech1}" if spob.special_tech1 > -1 and outfitters["Tech level #{spob.special_tech1}"]
                  entry :outfitter, "Tech level #{spob.special_tech2}" if spob.special_tech2 > -1 and outfitters["Tech level #{spob.special_tech2}"]
                  entry :outfitter, "Tech level #{spob.special_tech3}" if spob.special_tech3 > -1 and outfitters["Tech level #{spob.special_tech3}"]
                  entry :outfitter, "Tech level #{spob.special_tech4}" if spob.special_tech4 > -1 and outfitters["Tech level #{spob.special_tech4}"]
                  entry :outfitter, "Tech level #{spob.special_tech5}" if spob.special_tech5 > -1 and outfitters["Tech level #{spob.special_tech5}"]
                  entry :outfitter, "Tech level #{spob.special_tech6}" if spob.special_tech6 > -1 and outfitters["Tech level #{spob.special_tech6}"]
                  entry :outfitter, "Tech level #{spob.special_tech7}" if spob.special_tech7 > -1 and outfitters["Tech level #{spob.special_tech7}"]
                  entry :outfitter, "Tech level #{spob.special_tech8}" if spob.special_tech8 > -1 and outfitters["Tech level #{spob.special_tech8}"]
                end

                if spob.flags_match(Nova::Record::Spob::CanBuyShips)
                  spob.tech_level.times do |tl|
                    entry :shipyard, "Tech level #{tl}" if shipyards["Tech level #{tl}"]
                  end
                  entry :shipyard, "Tech level #{spob.special_tech1}" if spob.special_tech1 > -1 and shipyards["Tech level #{spob.special_tech1}"]
                  entry :shipyard, "Tech level #{spob.special_tech2}" if spob.special_tech2 > -1 and shipyards["Tech level #{spob.special_tech2}"]
                  entry :shipyard, "Tech level #{spob.special_tech3}" if spob.special_tech3 > -1 and shipyards["Tech level #{spob.special_tech3}"]
                  entry :shipyard, "Tech level #{spob.special_tech4}" if spob.special_tech4 > -1 and shipyards["Tech level #{spob.special_tech4}"]
                  entry :shipyard, "Tech level #{spob.special_tech5}" if spob.special_tech5 > -1 and shipyards["Tech level #{spob.special_tech5}"]
                  entry :shipyard, "Tech level #{spob.special_tech6}" if spob.special_tech6 > -1 and shipyards["Tech level #{spob.special_tech6}"]
                  entry :shipyard, "Tech level #{spob.special_tech7}" if spob.special_tech7 > -1 and shipyards["Tech level #{spob.special_tech7}"]
                  entry :shipyard, "Tech level #{spob.special_tech8}" if spob.special_tech8 > -1 and shipyards["Tech level #{spob.special_tech8}"]
                end
                #entry "required reputation", spob.min_coolness
                entry :tribute, spob.tribute
              end
              conf.write(file)
            end
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("planets.txt"))
        FileUtils.rm_rf("#{conv.images_export_dir}/land")
      end

    end
  end
end
