# https://github.com/fuzziqersoftware/resource_dasm/blob/master/audio_codecs.cc
class Ima4Packet < BinData::Record
  endian :big
  uint16 :header
  array :data, type: :uint8, initial_length: 32

  def predictor
    header & 0xFF80
  end

  def step_index
    header & 0x007F
  end
end

class Ima4
  def self.decode(data, size, stereo)
    index_table = [
        -1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8]
    step_table = [
        7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
        19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
        50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
        130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
        337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
        876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
        2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
        5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
        15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767]

    if size % (stereo ? 68 : 34) != 0
      raise "ima4 data size must be a multiple of 34 bytes"
    end

    result_data = Array.new(((size * 64) / 34), 0)

    channel_states = []

    base_packet = Ima4Packet.read(data)
    channel_states << {predictor: base_packet.predictor, step_index: base_packet.step_index, step: step_table[base_packet.step_index]}

    if stereo
      base_packet = Ima4Packet.read(data[34..-1])
      channel_states << {predictor: base_packet.predictor, step_index: base_packet.step_index, step: step_table[base_packet.step_index]}
    end

    (size / 34).times do |packet_index|
      packet = Ima4Packet.read(data[(packet_index * 34)..-1])
      channel = channel_states[stereo ? (packet_index & 1) : 0]
      output_offset = 0
      output_step = stereo ? 2 : 1

      if stereo
        output_offset = (packet_index & ~1) * 64 + (packet_index & 1)
      else
        output_offset = packet_index * 64
      end

      32.times do |x|
        value = packet.data[x]
        2.times do |y|
          nybble = value & 0x0F
          value >>= 4
          diff = 0

          if nybble & 4 != 0
            diff += channel[:step]
          end
          if nybble & 2 != 0
            diff += channel[:step] >> 1
          end
          if nybble & 1 != 0
            diff += channel[:step] >> 2;
          end

          diff += channel[:step] >> 3
          if nybble & 8 != 0
            diff = -diff
          end

          channel[:predictor] += diff

          if channel[:predictor] > 0x7FFF
            channel[:predictor] = 0x7FFF
          else
            if channel[:predictor] < -0x8000
              channel[:predictor] = -0x8000
            end

            result_data[output_offset] = channel[:predictor]
            output_offset += output_step

            channel[:step_index] += index_table[nybble]
            if channel[:step_index] < 0
              channel[:step_index] = 0
            else
              if channel[:step_index] > 88
                channel[:step_index] = 88
              end
              channel[:step] = step_table[channel[:step_index]]
            end
          end
        end
      end
    end

    if result_data.length > 0
      result_data.pack('s*')
    else
      puts "IMA4 ERROR EMPTY"
      ""
    end
  end
end