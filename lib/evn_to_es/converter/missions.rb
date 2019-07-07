module EvnToEs
  module Converter
    class Missions < Base

      def generate_position(key, pos)
        self.generate_config do
          case pos.first
          when :stellar
            if key == :system
              syst = pos.last.systs.first
              entry key, syst.uniq_name if syst.initially_available
            else
              entry key, pos.last.uniq_name
            end
          when :adj_system
            entry key do
              entry :neighbor, :system, pos.last.uniq_name
              entry :distance, 3 if key != :source
            end
          when :government
            entry key do
              entry :government, pos.last.uniq_name
              entry :distance, 3 if key != :source
            end
          when :not_government
            entry key do
              entry :not, :government, pos.last.uniq_name
              entry :distance, 3 if key != :source
            end
          when :government_ally
            entry key do
              entry :government, *pos.last.allies_govts.map(&:uniq_name)
              entry :distance, 3 if key != :source
            end
          when :government_ennemy
            entry key do
              entry :government, *pos.last.enemies_govts.map(&:uniq_name)
              entry :distance, 3 if key != :source
            end
          when :government_class
            entry key do
              entry :government, *pos.last.classes_govts.map(&:uniq_name)
              entry :distance, 3 if key != :source
            end
          when :not_government_class
            entry key do
              entry :not, :government, *pos.last.classes_govts.map(&:uniq_name)
              entry :distance, 3 if key != :source
            end
          else
            #raise "UNKNOWN #{pos.first}"
          end
        end
      end

      def convert(nova)
        File.open(conv.data_export_path("missions.txt"), 'w') do |file|
          link_missions_pers = {}
          nova.traverse(:pers) do |id, name, pers|
            if pers.link_mission > -1
              link_missions_pers[pers.link_mission.to_i] ||= []
              link_missions_pers[pers.link_mission.to_i] << id
            end
          end

          nova.traverse(:misn) do |id, name, misn|
            misn.print_debug if self.conv.verbose

            stopover_type = :none

            if misn.trav.first != :no_specific_stellar and misn.ret.first != :no_specific_stellar
              stopover_type = :return_with_stopover
            end

            if misn.trav.first != :no_specific_stellar and misn.ret.first == :no_specific_stellar
              stopover_type = :stopover_without_return
            end

            if misn.trav.first == :no_specific_stellar and misn.ret.first != :no_specific_stellar
              stopover_type = :return_without_stopover
            end

            avail_exp = EvnToEs::TestExpression.new(misn.avail_bits.to_s)

            unless avail_exp.will_never_happen
              conf = self.generate_config :mission, name do
                is_job = false
                case misn.avail_loc.to_i
                when Nova::Record::Misn::AvailFromMissionComputer
                  is_job = true
                  entry :job
                  entry :repeat
                when Nova::Record::Misn::AvailInBar
                  # default
                when Nova::Record::Misn::AvailFromShip
                  # entry :boarding
                  entry :assisting
                when Nova::Record::Misn::AvailInMainDialog
                  entry :landing
                when Nova::Record::Misn::AvailInTradingDialog
                  #entry :trading
                when Nova::Record::Misn::AvailInShipyardDialog
                  #entry :shipyarding
                when Nova::Record::Misn::AvailInOutfitDialog
                  #entry :outfitting
                else
                end

                if is_job
                  entry :description, EvnToEs::Description.new(nova, misn.desc_id, stopover_type: stopover_type) if misn.desc_id > 0
                else
                  entry :description, EvnToEs::Description.new(nova, misn.quick_brief, stopover_type: stopover_type) if misn.quick_brief > 0
                end
                entry :name, EvnToEs::VarSub.sub(misn.display_name, stopover_type: stopover_type)

                #if misn.can_abort == 0 and misn.flags_match(Nova::Record::Misn::DontShowArrow)
                #  entry :invisible
                #end

                if misn.flags_match(Nova::Record::Misn::Invisible)
                  entry :invisible
                end

                if misn.cargo_type > -1 and misn.cargo_qty != -1 and misn.cargo_qty != 0
                  if misn.cargo_type == 1000
                    if misn.cargo_qty != misn.cargo_qty.abs
                      entry :cargo, :random, (misn.cargo_qty.abs * 0.5).round, (misn.cargo_qty.abs * 1.5).round
                    else
                      entry :cargo, :random, misn.cargo_qty
                    end
                  else
                    commodities = nova.get(:str, 4000).strings
                    commodity = commodities[misn.cargo_type][:string].to_s
                    unless commodity
                      puts misn.cargo_type
                      junk = nova.get(:junk, misn.cargo_type + 128)
                      puts misn.cargo_type + 128
                      commodity = junk.uniq_name if junk
                    end

                    if commodity
                      if misn.cargo_qty != misn.cargo_qty.abs
                        entry :cargo, commodity, (misn.cargo_qty.abs * 0.5).round, (misn.cargo_qty.abs * 1.5).round
                      else
                        entry :cargo, commodity, misn.cargo_qty
                      end
                    end
                  end
                end

                if misn.src and misn.src.first != :no_specific_stellar
                  insert self.generate_position(:source, misn.src)
                else
                  # Any inhabited stellar.
                  entry :source do
                    entry :not, :government, "Uninhabited"
                  end
                end

                case stopover_type
                when :return_with_stopover
                  insert self.generate_position(:stopover, misn.trav)
                  insert self.generate_position(:destination, misn.ret)
                when :stopover_without_return
                  insert self.generate_position(:destination, misn.trav)
                when :return_without_stopover
                  insert self.generate_position(:destination, misn.ret)
                when :none
                  entry :destination do
                    entry :distance, 3
                  end
                end

                if misn.time_limit > 0
                  entry :deadline, misn.time_limit
                end

                entry :to, :offer do
                  if misn.avail_record > 0
                    if misn.src.first == :government
                      entry "reputation: #{misn.src.last.uniq_name}", :">=", misn.avail_record
                    end
                  end

                  if misn.avail_random < 100 && misn.avail_random >= 0
                    entry :random, :<, misn.avail_random
                  end

                  if misn.avail_rating > -1
                    entry "combat rating", :">=", misn.avail_rating
                  end

                  entry avail_exp
                end

                if misn.ship_dude
                  npc = nil
                  case misn.ship_goal
                  when Nova::Record::Misn::ShipGoalDestroy
                    npc = :kill
                  when Nova::Record::Misn::ShipGoalDisable
                    npc = :disable
                  when Nova::Record::Misn::ShipGoalBoard
                    npc = :board
                  when Nova::Record::Misn::ShipGoalEscort
                    npc = :accompany
                  when Nova::Record::Misn::ShipGoalObserve
                    npc = "scan cargo"
                  when Nova::Record::Misn::ShipGoalRescue
                    npc = :assist
                  when Nova::Record::Misn::ShipGoalChase
                    npc = :kill
                  when -1
                    npc = nil
                  end

                  entry :npc, npc do
                    npc_syst = misn.resolve_ship_syst
                    case npc_syst.first
                    when :system
                      entry :system, npc_syst.last.uniq_name if npc_syst.last.initially_available
                    when :initial_system
                      insert self.generate_position(:system, misn.src)
                    when :travel_system
                      insert self.generate_position(:system, misn.trav)
                    when :return_system
                      insert self.generate_position(:system, misn.ret)
                    when :player_system
                    when :government, :government_ally
                      entry :system do
                        entry :government, npc_syst.last.uniq_name if npc_syst.last
                      end
                    when :not_government
                      entry :system do
                        entry :not, :government, npc_syst.last.uniq_name
                      end
                    else
                    end

                    entry :government, misn.ship_dude.govt.uniq_name if misn.ship_dude.govt
                    entry :fleet, misn.ship_dude.uniq_name, misn.ship_count
                    personalities = []
                    if misn.ship_behav == Nova::Record::Misn::ShipBehaveAlwaysAttack
                      personalities << :nemesis
                      personalities << :waiting
                      personalities << :heroic
                    end
                    if misn.ship_dude.govt and misn.ship_dude.govt.flags_match(Nova::Record::Govt::Disabled)
                      personalities << :derelict
                    end

                    if personalities.length > 0
                      entry :personality, *personalities
                    end
                  end
                end

                if misn.aux_ship_dude

                  entry :npc do
                    npc_syst = misn.resolve_aux_ship_syst
                    case npc_syst.first
                    when :system
                      entry :system, npc_syst.last.uniq_name if npc_syst.last.initially_available
                    when :initial_system
                      insert self.generate_position(:system, misn.src)
                    when :travel_system
                      insert self.generate_position(:system, misn.trav)
                    when :return_system
                      insert self.generate_position(:system, misn.ret)
                    when :player_system
                    when :government, :government_ally
                      entry :system do
                        entry :government, npc_syst.last.uniq_name if npc_syst.last
                      end
                    when :not_government
                      entry :system do
                        entry :not, :government, npc_syst.last.uniq_name
                      end
                    else
                    end

                    entry :government, misn.aux_ship_dude.govt.uniq_name if misn.aux_ship_dude.govt
                    entry :fleet, misn.aux_ship_dude.uniq_name, misn.aux_ship_count
                    personalities = []
                    if misn.ship_behav == Nova::Record::Misn::ShipBehaveAlwaysAttack
                      personalities << :nemesis
                      personalities << :waiting
                      personalities << :heroic
                    end
                    if misn.aux_ship_dude.govt and misn.aux_ship_dude.govt.flags_match(Nova::Record::Govt::Disabled)
                      personalities << :derelict
                    end

                    if personalities.length > 0
                      entry :personality, *personalities
                    end
                  end
                end

                if misn.desc_id > 0
                  accept = misn.accept_button.to_s.strip
                  refuse = misn.refuse_button.to_s.strip

                  accept = "Yes" if accept.length == 0
                  refuse = "No" if refuse.length == 0
                  entry :on, :offer do
                    if misn.avail_ship
                      entry :require, misn.avail_ship.uniq_name
                    end

                    entry :conversation do
                      entry EvnToEs::Conversation.new(nova, misn.desc_id, stopover_type: stopover_type)
                      entry :choice do
                        entry EvnToEs::ConversationLine.new(accept) do
                          entry :goto, :accept
                        end
                        entry EvnToEs::ConversationLine.new(refuse) do
                          if misn.refuse_text <= 0
                            entry :decline
                          end
                        end
                      end
                      if misn.refuse_text > 0
                        entry EvnToEs::Conversation.new(nova, misn.refuse_text, stopover_type: stopover_type) do
                          entry :decline
                        end
                      end

                      entry :label, :accept
                      if misn.brief_text > 0
                        entry EvnToEs::Conversation.new(nova, misn.brief_text, stopover_type: stopover_type) do
                          entry :accept
                        end
                      else
                        if misn.load_carg_text > 0 and misn.pickup_mode == Nova::Record::Misn::PickupAtMissionStart
                          entry EvnToEs::Conversation.new(nova, misn.load_carg_text, stopover_type: stopover_type) do
                            entry :accept
                          end
                        else
                          entry EvnToEs::ConversationLine.new("___") do
                            entry :accept
                          end
                        end
                      end
                    end
                  end
                end

                entry :on, :accept do
                  # accept mission from this govt will reduce his ennemies player reputation
                  if misn.comp_govt
                    misn.comp_govt.enemies_govts.each do |ennemy|
                      if misn.comp_reward > 0
                        entry "reputation: #{ennemy.uniq_name}", :"-=", misn.comp_reward
                      else
                        entry "reputation: #{ennemy.uniq_name}", :"+=", misn.comp_reward.abs
                      end
                    end
                  end
                  if misn.on_accept.to_s.truncated.strip.length > 0
                    entry EvnToEs::SetExpression.new(misn.on_accept.to_s, nova)
                  end
                end

                entry :on, :decline do
                  if misn.on_refuse.to_s.truncated.strip.length > 0
                    entry EvnToEs::SetExpression.new(misn.on_refuse.to_s, nova)
                  end
                end

                if stopover_type == :return_with_stopover
                  entry :on, :stopover do
                    if misn.pickup_mode == Nova::Record::Misn::PickupAtTravelStel
                      if misn.load_carg_text > 0
                        entry :conversation do
                          entry EvnToEs::Conversation.new(nova, misn.load_carg_text, stopover_type: stopover_type)
                        end
                      end
                    end
                    if misn.dropoff_mode == Nova::Record::Misn::DropOffAtTravelStel
                      if misn.drop_carg_text > 0
                        entry :conversation do
                          entry EvnToEs::Conversation.new(nova, misn.drop_carg_text, stopover_type: stopover_type)
                        end
                      end
                    end
                  end
                end

                entry :on, :complete do
                  if misn.pay_val > 0
                    entry :payment, misn.pay_val
                  end
                  if misn.comp_govt
                    if misn.comp_reward > 0
                      entry "reputation: #{misn.comp_govt.uniq_name}", :"+=", misn.comp_reward
                    else
                      entry "reputation: #{misn.comp_govt.uniq_name}", :"-=", misn.comp_reward.abs
                    end
                  end
                  # considere on_ship_done at on complete
                  if misn.on_ship_done.to_s.truncated.strip.length > 0
                    entry EvnToEs::SetExpression.new(misn.on_ship_done.to_s, nova)
                  end
                  if misn.on_success.to_s.truncated.strip.length > 0
                    entry EvnToEs::SetExpression.new(misn.on_success.to_s, nova)
                  end

                  if stopover_type == :stopover_without_return or stopover_type == :return_without_stopover
                    if misn.pickup_mode == Nova::Record::Misn::PickupAtTravelStel
                      if misn.load_carg_text > 0
                        entry :conversation do
                          entry EvnToEs::Conversation.new(nova, misn.load_carg_text, stopover_type: stopover_type)
                        end
                      end
                    end
                    if misn.dropoff_mode == Nova::Record::Misn::DropOffAtTravelStel
                      if misn.drop_carg_text > 0
                        entry :conversation do
                          entry EvnToEs::Conversation.new(nova, misn.drop_carg_text, stopover_type: stopover_type)
                        end
                      end
                    end
                  end

                  if misn.comp_text > 0
                    entry :conversation do
                      entry EvnToEs::Conversation.new(nova, misn.comp_text, stopover_type: stopover_type)
                    end
                  end
                end

                entry :on, :fail do
                  if misn.comp_govt
                    if misn.comp_reward > 0
                      entry "reputation: #{misn.comp_govt.uniq_name}", :"-=", misn.comp_reward / 2.0
                    else
                      entry "reputation: #{misn.comp_govt.uniq_name}", :"+=", misn.comp_reward.abs / 2.0
                    end
                  end

                  if misn.on_failure.to_s.truncated.strip.length > 0
                    entry EvnToEs::SetExpression.new(misn.on_failure.to_s.truncated.strip, nova)
                  end
                  # considere on_abort at on fail
                  if misn.on_abort.to_s.truncated.strip.length > 0
                    entry EvnToEs::SetExpression.new(misn.on_abort.to_s, nova)
                  end
                  entry :dialog, EvnToEs::MultiLineDescription.new(nova, misn.fail_text, stopover_type: stopover_type) if misn.fail_text > 0
                end

              end
              conf.write(file)
            end
          end
        end
      end

      def clean(nova)
        FileUtils.rm_f(conv.data_export_path("missions.txt"))
      end

    end
  end
end
