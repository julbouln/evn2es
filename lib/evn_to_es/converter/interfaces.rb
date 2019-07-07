module EvnToEs
  module Converter
    class Interfaces < Base
      def convert(nova)
        nova.traverse(:intf) do |id, name, intf|
          intf.print_debug if self.conv.verbose
        end

        nova.traverse(:colr) do |id, name, colr|
          colr.print_debug if self.conv.verbose
        end

        colr = nova.get(:colr, 128)
        intf = nova.get(:intf, 128) # use default only for now

        File.open(conv.data_export_path("interfaces2.txt"), 'w') do |file|
          # menu background
          conf = self.generate_config :interface, "menu background" do
            entry :sprite, "pict/08000" do
            end
          end
          conf.write(file)

          # main menu
          conf = self.generate_config :interface, "main menu" do
            FileUtils.mkdir_p("evn/images/ui2")

            # 338x63 (11) 08030
            system("convert -extract 338x63+0+630 evn/images/pict/08030.png evn/images/ui2/menu_l1.png")
            entry :sprite, "ui2/menu_l1" do
              entry :center, 0, colr.button1y - 768 / 2 + 32
            end
            # 351x64 (10) 08031
            system("convert -extract 351x64+0+576 evn/images/pict/08031.png evn/images/ui2/menu_l2.png")
            entry :sprite, "ui2/menu_l2" do
              entry :center, 0, colr.button2y - 768 / 2 + 32
            end
            # 351X65 (11) 08032
            system("convert -extract 351x65+0+650 evn/images/pict/08032.png evn/images/ui2/menu_l3.png")
            entry :sprite, "ui2/menu_l3" do
              entry :center, 0, colr.button3y - 768 / 2 + 32
            end

            #7.times do |i|
            #  system("convert -extract 654x209+0+#{209*i} evn/images/pict/08010.png evn/images/ui2/logo-#{i}.png")
            #end
            system("convert -extract 654x209+0+0 evn/images/pict/08010.png evn/images/ui2/logo.png")
            entry :sprite, "ui2/logo" do
              entry :center, colr.logo_x - 1024 / 2 + 654 / 2, colr.logo_y - 768 / 2 + 209 / 2
            end

            entry :button, :n, "_New Pilot" do
              entry :center, colr.button1x - 1024 / 2 + 45 + 8, colr.button1y - 768 / 2 + 30 + 8
              entry :dimensions, 90, 30
            end

            entry :button, :l, "_Open Pilot" do
              entry :center, colr.button2x - 1024 / 2 + 45, colr.button2y - 768 / 2 + 30
              entry :dimensions, 90, 30
            end

            entry :button, :q, "_Quit Nova" do
              entry :center, colr.button3x - 1024 / 2 + 45, colr.button3y - 768 / 2 + 30
              entry :dimensions, 90, 30
            end

            entry :button, :p, "_Set Prefs" do
              entry :center, colr.button5x - 1024 / 2 + 45 + 8, colr.button5y - 768 / 2 + 30
              entry :dimensions, 90, 30
            end

            entry :visible, :if, "pilot loaded"
            entry :button, :e, "_Enter Ship" do
              entry :center, colr.button4x - 1024 / 2 + 45 + 8, colr.button4y - 768 / 2 + 30 + 8
              entry :dimensions, 90, 30
            end

          end
          conf.write(file)

          # menu player info
          conf = self.generate_config :interface, "menu player info" do
            entry :outline, "ship sprite" do
              entry :center, 0, 300
              entry :dimensions, 120, 120
            end

            left = -200
            right = 100
            top = 250

            entry :label, "Pilot Name" do
              entry :from, left, top
              entry :align, :left
            end
            entry :string, "pilot" do
              entry :from, left, top + 10
              entry :align, :left
            end

            entry :label, "Ship Name" do
              entry :from, left, top + 30
              entry :align, :left
            end
            entry :string, "ship" do
              entry :from, left, top + 40
              entry :align, :left
            end

            entry :label, "Credits" do
              entry :from, left, top + 60
              entry :align, :left
            end
            entry :string, "credits" do
              entry :from, left, top + 70
              entry :align, :left
            end

            entry :label, "System" do
              entry :from, right, top
              entry :align, :left
            end
            entry :string, "system" do
              entry :from, right, top + 10
              entry :align, :left
            end

            entry :label, "Planet" do
              entry :from, right, top + 30
              entry :align, :left
            end
            entry :string, "planet" do
              entry :from, right, top + 40
              entry :align, :left
            end

            entry :label, "Date" do
              entry :from, right, top + 60
              entry :align, :left
            end
            entry :string, "date" do
              entry :from, right, top + 70
              entry :align, :left
            end
          end
          conf.write(file)


          # TODO: endless-sky plugins do not let to position or resize planet description
          if false
            conf = self.generate_config :interface, "planet" do
              entry :sprite, "pict/08500" do
                entry :center, 0, 0
              end
              entry :image, "land" do
                entry :center, 0, -113
                entry :dimensions, 612, 285
              end

            end
            conf.write(file)
          end
          # TODO: endless-sky plugins do not let to configure segment value
          if false

            shield_col = Nova::Color.to_rgb(intf.shield)
            armor_col = Nova::Color.to_rgb(intf.armor)
            fuel_col = Nova::Color.to_rgb(intf.fuel_full)

            conf = self.generate_config :color, "shield", (shield_col[0] / 255.0).round(3),
                                        (shield_col[1] / 255.0).round(3),
                                        (shield_col[2] / 255.0).round(3), 1.0 do

            end
            conf.write(file)

            conf = self.generate_config :color, "armor", (armor_col[0] / 255.0).round(3),
                                        (armor_col[1] / 255.0).round(3),
                                        (armor_col[2] / 255.0).round(3), 1.0 do

            end
            conf.write(file)

            conf = self.generate_config :color, "fuel_full", (fuel_col[0] / 255.0).round(3),
                                        (fuel_col[1] / 255.0).round(3),
                                        (fuel_col[2] / 255.0).round(3), 1.0 do

            end
            conf.write(file)


            # menu player info
            if self.conv.patched
              conf = self.generate_config :interface, "hud" do
                entry :anchor, :top, :right
                entry :sprite, "pict/00700" do
                  entry :center, -97, 383
                end

                entry :point, "radar" do
                  entry :center, -97, 97

                end
                entry :value, "radar radius", 80
                entry :value, "radar pointer radius", 90


                entry :bar, "shields", 1 do
                  entry :from, -(intf.shield_area.right - intf.shield_area.left), intf.shield_area.top
                  entry :dimensions, intf.shield_area.right - intf.shield_area.left, 0
                  entry :color, "shield"
                  entry :size, intf.shield_area.bottom - intf.shield_area.top
                end

                entry :bar, "hull", 1 do
                  entry :from, -(intf.armor_area.right - intf.armor_area.left), intf.armor_area.top
                  entry :dimensions, intf.armor_area.right - intf.armor_area.left, 0
                  entry :color, "armor"
                  entry :size, intf.armor_area.bottom - intf.armor_area.top
                end

                entry :bar, "disabled hull", 1 do
                  entry :from, -(intf.armor_area.right - intf.armor_area.left), intf.armor_area.top
                  entry :dimensions, intf.armor_area.right - intf.armor_area.left, 0
                  entry :color, "armor"
                  entry :size, intf.armor_area.bottom - intf.armor_area.top
                end

                entry :bar, "fuel", 1 do
                  entry :from, -(intf.fuel_area.right - intf.fuel_area.left), intf.fuel_area.top
                  entry :dimensions, intf.fuel_area.right - intf.fuel_area.left, 0
                  entry :color, "fuel_full"
                  entry :size, intf.fuel_area.bottom - intf.fuel_area.top
                end

                entry :string, "location" do
                  entry :from, -90, intf.nav_area.top + 4
                  entry :color, "medium"
                end

                entry :string, "target name" do
                  entry :center, -97, intf.targ_area.top
                  entry :color, "bright"
                end
                entry :string, "target type" do
                  entry :center, -97, intf.targ_area.top + 15
                  entry :color, "medium"
                end
                entry :string, "target government" do
                  entry :center, -97, intf.targ_area.top + 30
                  entry :color, "medium"
                end

                entry :point, "target" do
                  entry :center, -97, intf.targ_area.top + 60
                  entry :dimensions, 140, 140
                end
                entry :value, "target radius", 70
                entry :outline, "target sprite" do
                  entry :center, -97, intf.targ_area.top + 60
                  entry :dimensions, 70, 70
                  entry :colored
                end

                entry :string, "target shields" do
                  entry :center, -97, intf.targ_area.top + 90
                  entry :color, "medium"
                end

              end
              conf.write(file)
            end

          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("interfaces2.txt"))
      end

    end
  end
end
