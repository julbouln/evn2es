module Nova
  module Raw
    class Snd < BinData::Record
      endian :big
      uint16 :format_type
      uint16 :data_type_cnt
      array :data_types, :initial_length => :data_type_cnt do
        uint16 :data_type
        uint32 :initialization_opts
      end
      uint16 :command_cnt
      array :commands, :initial_length => :command_cnt do
        uint16 :command
        uint16 :param1
        uint32 :param2
      end
    end

    class SndHeader < BinData::Record
      endian :big
      uint32 :data_pointer
      uint32 :data_length
      uint32 :sample_rate
      uint32 :loop_start
      uint32 :loop_end
      uint8 :encoding
      uint8 :base_frequency
    end

    class SndEncoded < BinData::Record
      endian :big
      uint32 :frame_count
      array :aiff_buff, type: :uint8, initial_length: 10
      uint32 :marker_chunk
      array :compression_format, type: :uint8, initial_length: 5
      uint32 :reserved
      uint32 :state_var
      uint32 :leftover_block
      int16 :compression_id
      uint16 :packet_size
      uint16 :snth_id
      uint16 :sample_size
    end

    class Str < BinData::Record
      endian :big
      uint16 :cnt
      array :strings, initial_length: :cnt do
        uint8 :len
        string :string, read_length: :len
      end
    end

    class PixelMapHeader < BinData::Record
      endian :big
      uint32 :base_addr # unused for resources
      uint16 :flags_row_bytes
      uint16 :x
      uint16 :y
      uint16 :h
      uint16 :w
      uint16 :version
      uint16 :pack_format
      uint32 :pack_size
      uint32 :h_res
      uint32 :v_res
      uint16 :pixel_type
      uint16 :pixel_size # bits per pixel
      uint16 :component_count
      uint16 :component_size
      uint32 :plane_offset
      uint32 :color_table_offset
      uint32 :reserved
    end

    class CicnHeader < BinData::Record
      endian :big
      # pixMap fields
      pixel_map_header :pix_map

      # mask bitmap fields
      uint32 :unknown1
      uint16 :mask_row_bytes
      uint32 :unknown2
      uint16 :mask_h
      uint16 :mask_w

      # 1-bit icon bitmap fields
      uint32 :unknown3
      uint16 :bitmap_row_bytes
      uint32 :unknown4
      uint16 :bitmap_h
      uint16 :bitmap_w

      # icon data fields
      uint32 :icon_data # ignored
    end

  end
end