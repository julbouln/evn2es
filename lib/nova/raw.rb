# automatically generated, do not edit
require 'bindata'
module Nova
 module Raw

  class Rect < BinData::Record
   endian :big
   int16 :top
   int16 :left
   int16 :bottom
   int16 :right
  end

  class NovaControlBits < BinData::Record
   endian :big
   string :bits, length: 1250, trim_padding: true
  end

  class Boom < BinData::Record
   endian :big
   int16 :frame_advance
   int16 :sound_index
   int16 :graphic_index
  end

  class Char < BinData::Record
   endian :big
   int32 :start_cash
   int16 :start_ship_type
   array :start_system, type: :int16, initial_length: 4
   array :start_govt, type: :int16, initial_length: 4
   array :start_status, type: :int16, initial_length: 4
   int16 :start_kills
   array :intro_pict_id, type: :int16, initial_length: 4
   array :intro_pict_delay, type: :int16, initial_length: 4
   int16 :intro_text_id
   string :on_start, length: 256, trim_padding: true
   int16 :flags
   int16 :start_day
   int16 :start_month
   int16 :start_year
   string :prefix, length: 16, trim_padding: true
   string :suffix, length: 16, trim_padding: true
   array :unused_a, type: :int16, initial_length: 8
  end

  class Colr < BinData::Record
   endian :big
   int32 :button_up
   int32 :button_down
   int32 :button_grey
   string :menu_font, length: 64, trim_padding: true
   int16 :menu_font_size
   int32 :menu_color1
   int32 :menu_color2
   int32 :grid_bright
   int32 :grid_dim
   rect :prog_area
   int32 :prog_bright
   int32 :prog_dim
   int32 :prog_outline
   int16 :button1x
   int16 :button1y
   int16 :button2x
   int16 :button2y
   int16 :button3x
   int16 :button3y
   int16 :button4x
   int16 :button4y
   int16 :button5x
   int16 :button5y
   int16 :button6x
   int16 :button6y
   int32 :floating_map
   int32 :list_text
   int32 :list_bkgnd
   int32 :list_hilite
   int32 :escort_hilite
   string :button_font, length: 64, trim_padding: true
   int16 :button_font_sz
   int16 :logo_x
   int16 :logo_y
   int16 :rollover_x
   int16 :rollover_y
   int16 :slide1x
   int16 :slide1y
   int16 :slide2x
   int16 :slide2y
   int16 :slide3x
   int16 :slide3y
  end

  class Cron < BinData::Record
   endian :big
   int16 :first_day
   int16 :first_month
   int16 :first_year
   int16 :last_day
   int16 :last_month
   int16 :last_year
   int16 :random
   int16 :duration
   int16 :pre_holdoff
   int16 :post_holdoff
   int16 :ind_news_str
   int16 :flags
   string :enable_on, length: 254 + 1, trim_padding: true
   string :on_start, length: 254 + 1, trim_padding: true
   string :on_end, length: 255 + 1, trim_padding: true
   int32 :contributes0
   int32 :contributes1
   int32 :require0
   int32 :require1
   array :news_govt, type: :int16, initial_length: 4
   array :govt_news_string, type: :int16, initial_length: 4
  end

  class Desc < BinData::Record
   endian :big
   string :description, length: 1, trim_padding: true
  end

  class DescCoda < BinData::Record
   endian :big
   int16 :graphic
   string :movie, length: 32, trim_padding: true
   int16 :flags
  end

  class Deqt < BinData::Record
   endian :big
   int16 :flags
  end

  class Dude < BinData::Record
   endian :big
   int16 :ai_type
   int16 :govt
   int16 :booty
   int16 :info_types
   array :ship_types, type: :int16, initial_length: 16
   array :probs, type: :int16, initial_length: 16
   array :unused_a, type: :int16, initial_length: 8
  end

  class Flet < BinData::Record
   endian :big
   int16 :lead_ship_type
   array :escort_ship_type, type: :int16, initial_length: 4
   array :escort_min, type: :int16, initial_length: 4
   array :escort_max, type: :int16, initial_length: 4
   int16 :govt
   int16 :link_syst
   string :activate_on, length: 256, trim_padding: true
   int16 :quote
   int16 :flags
   array :unused_a, type: :int16, initial_length: 8
  end

  class Intf < BinData::Record
   endian :big
   int32 :bright_text
   int32 :dim_text
   rect :radar_area
   int32 :bright_radar
   int32 :dim_radar
   rect :shield_area
   int32 :shield
   rect :armor_area
   int32 :armor
   rect :fuel_area
   int32 :fuel_full
   int32 :fuel_partial
   rect :nav_area
   rect :weap_area
   rect :targ_area
   rect :cargo_area
   string :status_font, length: 64, trim_padding: true
   int16 :stat_font_size
   int16 :subtitle_size
   int16 :status_bkgnd
  end

  class Junk < BinData::Record
   endian :big
   array :sold_at, type: :int16, initial_length: 8
   array :bought_at, type: :int16, initial_length: 8
   int16 :base_price
   int16 :flags
   int16 :scan_mask
   string :lc_name, length: 63 + 1, trim_padding: true
   string :abbrev, length: 63 + 1, trim_padding: true
   string :buy_on, length: 254 + 1, trim_padding: true
   string :sell_on, length: 254 + 1, trim_padding: true
  end

  class Govt < BinData::Record
   endian :big
   int16 :voice_type
   int16 :flags
   int16 :flags2
   int16 :scan_fine
   int16 :crime_tol
   int16 :smug_penalty
   int16 :disab_penalty
   int16 :board_penalty
   int16 :kill_penalty
   int16 :shoot_penalty
   int16 :initial_rec
   int16 :max_odds
   array :classes, type: :int16, initial_length: 4
   array :allies, type: :int16, initial_length: 4
   array :enemies, type: :int16, initial_length: 4
   int16 :skill_mult
   int16 :scan_mask
   string :comm_name, length: 16, trim_padding: true
   string :target_code, length: 16, trim_padding: true
   int32 :require0
   int32 :require1
   array :inh_jam, type: :int16, initial_length: 4
   string :medium_name, length: 64, trim_padding: true
   int32 :color
   int32 :ship_color
   int16 :intf
   int16 :news_pict
   array :unused_a, type: :int16, initial_length: 8
  end

  class Misn < BinData::Record
   endian :big
   int16 :avail_stel
   int16 :unused1
   int16 :avail_loc
   int16 :avail_record
   int16 :avail_rating
   int16 :avail_random
   int16 :travel_stel
   int16 :return_stel
   int16 :cargo_type
   int16 :cargo_qty
   int16 :pickup_mode
   int16 :dropoff_mode
   int16 :scan_govt
   int16 :unused2
   int32 :pay_val
   int16 :ship_count
   int16 :ship_syst
   int16 :ship_dude
   int16 :ship_goal
   int16 :ship_behav
   int16 :ship_name_id
   int16 :ship_start
   int16 :comp_govt
   int16 :comp_reward
   int16 :ship_sub_title
   int16 :brief_text
   int16 :quick_brief
   int16 :load_carg_text
   int16 :drop_carg_text
   int16 :comp_text
   int16 :fail_text
   int16 :time_limit
   int16 :can_abort
   int16 :ship_done_text
   int16 :unused3
   int16 :aux_ship_count
   int16 :aux_ship_dude
   int16 :aux_ship_syst
   int16 :unused4
   int16 :flags
   int16 :flags2
   int16 :unused6
   int16 :unused7
   int16 :refuse_text
   int16 :avail_ship_type
   string :avail_bits, length: 254 + 1, trim_padding: true
   string :on_accept, length: 254 + 1, trim_padding: true
   string :on_refuse, length: 254 + 1, trim_padding: true
   string :on_success, length: 254 + 1, trim_padding: true
   string :on_failure, length: 254 + 1, trim_padding: true
   string :on_abort, length: 254 + 1, trim_padding: true
   int32 :require0
   int32 :require1
   int16 :date_post_inc
   string :on_ship_done, length: 254 + 1, trim_padding: true
   string :accept_button, length: 31 + 1, trim_padding: true
   string :refuse_button, length: 31 + 1, trim_padding: true
   int16 :disp_weight
   array :unused_a, type: :int16, initial_length: 8
  end

  class Nebu < BinData::Record
   endian :big
   int16 :x_pos
   int16 :y_pos
   int16 :x_size
   int16 :y_size
   string :active_on, length: 254 + 1, trim_padding: true
   string :on_explore, length: 254 + 1, trim_padding: true
   array :unused_a, type: :int16, initial_length: 8
  end

  class Oops < BinData::Record
   endian :big
   int16 :stellar
   int16 :commodity
   int16 :price_delta
   int16 :duration
   int16 :freq
   string :activate_on, length: 256, trim_padding: true
   array :unused_a, type: :int16, initial_length: 8
  end

  class Outf < BinData::Record
   endian :big
   int16 :disp_weight
   int16 :mass
   int16 :tech_level
   int16 :mod_type
   int16 :mod_val
   int16 :max_
   int16 :flags
   int32 :cost
   int16 :mod_type2
   int16 :mod_val2
   int16 :mod_type3
   int16 :mod_val3
   int16 :mod_type4
   int16 :mod_val4
   int32 :contributes0
   int32 :contributes1
   int32 :require0
   int32 :require1
   string :availability, length: 254 + 1, trim_padding: true
   string :on_purchase, length: 254 + 1, trim_padding: true
   string :on_sell, length: 254 + 1, trim_padding: true
   string :short_name, length: 63 + 1, trim_padding: true
   string :lc_name, length: 63 + 1, trim_padding: true
   string :lc_plural, length: 64 + 1, trim_padding: true
   int16 :item_class
   int16 :scan_mask
   int16 :buy_random
   int16 :require_govt
   array :unused_a, type: :int16, initial_length: 8
  end

  class Pers < BinData::Record
   endian :big
   int16 :link_syst
   int16 :govt
   int16 :ai_type
   int16 :aggress
   int16 :coward
   int16 :ship_type
   array :weap_type, type: :int16, initial_length: 4
   array :weap_count, type: :int16, initial_length: 4
   array :ammo_load, type: :int16, initial_length: 4
   int32 :credits
   int16 :shield_mod
   int16 :hail_pict
   int16 :comm_quote
   int16 :hail_quote
   int16 :link_mission
   int16 :flags
   string :activate_on, length: 256, trim_padding: true
   int16 :grant_class
   int16 :grant_count
   int16 :grant_prob
   string :sub_title, length: 64, trim_padding: true
   int32 :ship_color
   int16 :flags2
   array :unused_a, type: :int16, initial_length: 8
  end

  class Rank < BinData::Record
   endian :big
   int16 :weight
   int16 :govt
   int16 :price_mod
   int32 :salary
   int32 :salary_cap
   int32 :contributes0
   int32 :contributes1
   int16 :flags
   string :conv_name, length: 63 + 1, trim_padding: true
   string :short_name, length: 63 + 1, trim_padding: true
  end

  class Roid < BinData::Record
   endian :big
   int16 :strength
   int16 :spin_rate
   int16 :yield_type
   int16 :yield_qty
   int16 :part_count
   int32 :part_color
   array :frag_type, type: :int16, initial_length: 2
   int16 :frag_count
   int16 :explode_type
   int16 :mass
   array :unused_a, type: :int16, initial_length: 8
  end

  class RLEPixelData < BinData::Record
   endian :big
   int16 :width
   int16 :height
   int16 :depth
   int16 :palette
   int16 :nframes
   int16 :reserved1
   int16 :reserved2
   int16 :reserved3
   string :tokens, length: 1, trim_padding: true
  end

  class Shan < BinData::Record
   endian :big
   int16 :base_image_id
   int16 :base_mask_id
   int16 :base_set_count
   int16 :base_x_size
   int16 :base_y_size
   int16 :base_transp
   int16 :alt_image_id
   int16 :alt_mask_id
   int16 :alt_set_count
   int16 :alt_x_size
   int16 :alt_y_size
   int16 :glow_image_id
   int16 :glow_mask_id
   int16 :glow_x_size
   int16 :glow_y_size
   int16 :light_image_id
   int16 :light_mask_id
   int16 :light_x_size
   int16 :light_y_size
   int16 :weap_image_id
   int16 :weap_mask_id
   int16 :weap_x_size
   int16 :weap_y_size
   int16 :flags
   int16 :anim_delay
   int16 :weap_decay
   int16 :frames_per
   int16 :blink_mode
   int16 :blink_a
   int16 :blink_b
   int16 :blink_c
   int16 :blink_d
   int16 :shield_img_id
   int16 :shield_mask_id
   int16 :shield_x_size
   int16 :shield_y_size
   array :gun_pos_x, type: :int16, initial_length: 4
   array :gun_pos_y, type: :int16, initial_length: 4
   array :turret_pos_x, type: :int16, initial_length: 4
   array :turret_pos_y, type: :int16, initial_length: 4
   array :guided_pos_x, type: :int16, initial_length: 4
   array :guided_pos_y, type: :int16, initial_length: 4
   array :beam_pos_x, type: :int16, initial_length: 4
   array :beam_pos_y, type: :int16, initial_length: 4
   int16 :up_compress_x
   int16 :up_compress_y
   int16 :dn_compress_x
   int16 :dn_compress_y
   array :gun_pos_z, type: :int16, initial_length: 4
   array :turret_pos_z, type: :int16, initial_length: 4
   array :guided_pos_z, type: :int16, initial_length: 4
   array :beam_pos_z, type: :int16, initial_length: 4
   array :unused_a, type: :int16, initial_length: 8
  end

  class Ship < BinData::Record
   endian :big
   int16 :holds
   int16 :shield
   int16 :accel
   int16 :speed
   int16 :maneuver
   int16 :fuel
   int16 :free_mass
   int16 :armor
   int16 :shield_regen
   array :w_type, type: :int16, initial_length: 4
   array :w_count, type: :int16, initial_length: 4
   array :ammo, type: :int16, initial_length: 4
   int16 :max_gun
   int16 :max_tur
   int16 :tech_level
   int32 :cost
   int16 :death_delay
   int16 :armor_rech
   int16 :explode1
   int16 :explode2
   int16 :disp_weight
   int16 :mass
   int16 :length_
   int16 :inherent_ai
   int16 :crew
   int16 :strength
   int16 :inherent_govt
   int16 :flags
   int16 :pod_count
   array :default_items, type: :int16, initial_length: 4
   array :item_count, type: :int16, initial_length: 4
   int16 :fuel_regen
   int16 :skill_var
   int16 :flags2
   int32 :contributes0
   int32 :contributes1
   string :availability, length: 254 + 1, trim_padding: true
   string :appear_on, length: 254 + 1, trim_padding: true
   string :on_purchase, length: 255 + 1, trim_padding: true
   int16 :deionize
   int16 :ionize_max
   int16 :key_carried
   array :default_items2, type: :int16, initial_length: 4
   array :item_count2, type: :int16, initial_length: 4
   int32 :require0
   int32 :require1
   int16 :buy_random
   int16 :hire_random
   array :unused_block, type: :int16, initial_length: 34
   string :on_capture, length: 254 + 1, trim_padding: true
   string :on_retire, length: 254 + 1, trim_padding: true
   string :short_name, length: 63 + 1, trim_padding: true
   string :comm_name, length: 31 + 1, trim_padding: true
   string :long_name, length: 127 + 1, trim_padding: true
   string :movie_file, length: 31 + 1, trim_padding: true
   array :w_type2, type: :int16, initial_length: 4
   array :w_count2, type: :int16, initial_length: 4
   array :ammo2, type: :int16, initial_length: 4
   string :sub_title, length: 63 + 1, trim_padding: true
   int16 :flags3
   int16 :upgrade_to
   int32 :esc_upgrd_cost
   int32 :esc_sell_value
   int16 :escort_type
   array :unused_a, type: :int16, initial_length: 8
  end

  class Spin < BinData::Record
   endian :big
   int16 :sprites_id
   int16 :masks_id
   int16 :x_size
   int16 :y_size
   int16 :nx
   int16 :ny
  end

  class Spob < BinData::Record
   endian :big
   int16 :x_pos
   int16 :y_pos
   int16 :spob_type
   int32 :flags
   int16 :tribute
   int16 :tech_level
   int16 :special_tech1
   int16 :special_tech2
   int16 :special_tech3
   int16 :govt
   int16 :min_coolness
   int16 :cust_pic_id
   int16 :cust_snd_id
   int16 :def_dude
   int16 :def_count
   int16 :flags2
   int16 :anim_delay
   int16 :frame0_bias
   array :hyper_link, type: :int16, initial_length: 8
   string :on_dominate, length: 254 + 1, trim_padding: true
   string :on_release, length: 254 + 1, trim_padding: true
   int32 :fee
   int16 :gravity
   int16 :weapon
   int32 :strength
   int16 :dead_type
   int16 :dead_time
   int16 :explod_type
   string :on_destroy, length: 254 + 1, trim_padding: true
   string :on_regen, length: 254 + 1, trim_padding: true
   int16 :special_tech4
   int16 :special_tech5
   int16 :special_tech6
   int16 :special_tech7
   int16 :special_tech8
   array :unused_a, type: :int16, initial_length: 8
  end

  class Syst < BinData::Record
   endian :big
   int16 :x_pos
   int16 :y_pos
   array :con, type: :int16, initial_length: 16
   array :nav, type: :int16, initial_length: 16
   array :dude_types, type: :int16, initial_length: 8
   array :probs, type: :int16, initial_length: 8
   int16 :avg_ships
   int16 :govt
   int16 :message
   int16 :asteroids
   int16 :interference
   array :person, type: :int16, initial_length: 8
   array :person_prob, type: :int16, initial_length: 8
   int32 :bkgnd_color
   int16 :murk
   int16 :ast_types
   string :visiblility, length: 256, trim_padding: true
   int16 :reinf_fleet
   int16 :reinf_time
   int16 :reinf_intrval
   array :unused_a, type: :int16, initial_length: 8
  end

  class Weap < BinData::Record
   endian :big
   int16 :reload
   int16 :count_
   int16 :mass_dmg
   int16 :energy_dmg
   int16 :guidance
   int16 :speed
   int16 :ammo_type
   int16 :graphic
   int16 :inaccuracy
   int16 :sound
   int16 :impact
   int16 :explod_type
   int16 :prox_radius
   int16 :blast_radius
   int16 :flags
   int16 :seeker
   int16 :smoke_set
   int16 :decay
   int16 :particles
   int16 :part_vel
   int16 :part_life_min
   int16 :part_life_max
   int32 :part_color
   int16 :beam_length
   int16 :beam_width
   int16 :falloff
   int32 :beam_color
   int32 :corona_color
   int16 :sub_count
   int16 :sub_type
   int16 :sub_theta
   int16 :sub_limit
   int16 :prox_safety
   int16 :flags2
   int16 :ionization
   int16 :hit_particles
   int16 :hit_part_life
   int16 :hit_part_vel
   int32 :hit_part_color
   int16 :recoil
   int16 :exit_type
   int16 :burst_count
   int16 :burst_reload
   int16 :jam_vuln1
   int16 :jam_vuln2
   int16 :jam_vuln3
   int16 :jam_vuln4
   int16 :flags3
   int16 :durability
   int16 :guided_turn
   int16 :max_ammo
   int16 :li_density
   int16 :li_amplitude
   int32 :ionize_color
   array :unused_a, type: :int16, initial_length: 8
  end

  class Year < BinData::Record
   endian :big
   int16 :day
   int16 :month
   int16 :year
   string :prefix, length: 16, trim_padding: true
   string :suffix, length: 15, trim_padding: true
  end
 end
end
