# https://github.com/dmaulikr/OpenNova/blob/master/ResourceKit/ResourceFork/Parsers/RKRLEResourceParser.m
require 'oily_png'
class Rle

  RLEOpCode_EndOfFrame = 0x00
  RLEOpCode_LineStart = 0x01
  RLEOpCode_PixelData = 0x02
  RLEOpCode_TransparentRun = 0x03
  RLEOpCode_PixelRun = 0x04

  def initialize(header, raw_data)
    @header = header
    @data = raw_data
    @pos = 0

    @sprites = {}

    @header.nframes.times do |frame|
      @sprites[frame] = ChunkyPNG::Image.new(@header.width.to_i, @header.height.to_i, ChunkyPNG::Color::TRANSPARENT)
    end
  end

  def write_pixel_data(frame, pix, offset)
    y = ((offset) / @header.width).to_i
    x = ((offset) % @header.width).to_i

    if x >= @header.width or y >= @header.height
      puts "offset:#{offset} x:#{x} y:#{y} w:#{@header.width} h:#{@header.height}"
    end

    col = ChunkyPNG::Color.rgba(*pix)
    @sprites[frame].set_pixel(x, y, col)
  end

  def write_pixel_data_variant0(frame, pixel, mask, offset)
    pix = []
    pix[2] = (pixel & 0x001F) << 3
    pix[1] = (pixel & 0x03E0) >> 2
    pix[0] = (pixel & 0x7C00) >> 7
    pix[3] = 0xFF

    self.write_pixel_data(frame, pix, offset)
  end

  def write_pixel_data_variant1(frame, pixel, mask, offset)
    pix = []
    pix[2] = (pixel & 0x001F0000) << 13
    pix[1] = (pixel & 0x03E00000) >> 18
    pix[0] = (pixel & 0x7C000000) >> 23
    pix[3] = 0xFF

    self.write_pixel_data(frame, pix, offset)
  end

  def write_pixel_data_variant2(frame, pixel, mask, offset)
    pix = []
    pix[2] = (pixel & 0x0000001F) << 3
    pix[1] = (pixel & 0x000003E0) >> 2
    pix[0] = (pixel & 0x00007C00) >> 7
    pix[3] = 0xFF

    self.write_pixel_data(frame, pix, offset)
  end

  def read_byte
    val = @data[@pos..@pos]
    @pos += 1
    val
  end

  def read_word
    val = @data[@pos..(@pos + 1)]
    @pos += 2
    val.unpack("S>").first
  end

  def read_dword
    val = @data[@pos..(@pos + 3)]
    @pos += 4
    val.unpack("L>").first
  end

  def write(dir, out)
    i = 0
    @sprites.each do |frame, sprite|
      sprite.save("#{dir}/#{out}_#{"%03d" % i}.png", :fast_rgba)
      i += 1
    end
  end

  def convert
    @pos += 16

    if (@header.depth != 16)
      raise "Invalid colour depth in RLËD resource."
    end

    position = 0
    row_start = 0
    current_line = -1
    current_offset = 0
    opcode = 0
    count = 0
    pixel = 0
    current_frame = 0
    pixel_run = 0

    while (true) do
#			puts "@pos: #{@pos}"
      if (@pos >= @data.length)
        raise "Early End-of-Resource encountered in RLËD"
      end

      position = @pos

      if ((row_start != 0) && (((position - row_start) & 0x03) != 0))
        position += 4 - ((position - row_start) & 0x03)
        @pos += 4 - (count & 0x03)
      end

      count = self.read_dword
      opcode = (count & 0xFF000000) >> 24
      count &= 0x00FFFFFF

      case opcode
      when RLEOpCode_EndOfFrame
        if (current_line != @header.height - 1)
          raise "Incorrect number of scanlines in RLËD resource #{current_line}/#{@header.height}"
        end
        current_frame += 1
        if current_frame >= @header.nframes
          return
        end
        current_line = -1
      when RLEOpCode_LineStart
        current_line += 1
        current_offset = current_line * @header.width
        row_start = @pos
      when RLEOpCode_PixelData
        (count / 2).times do |i|
          pixel = self.read_word
          self.write_pixel_data_variant0(current_frame, pixel, 0xFF, current_offset)
          current_offset += 1
        end

        if (count & 0x03) != 0
          @pos += 4 - (count & 0x03)
        end
      when RLEOpCode_TransparentRun
        current_offset += (count >> ((@header.depth >> 3) - 1))
      when RLEOpCode_PixelRun
        pixel_run = self.read_dword
        (count / 4).times do |i|
          self.write_pixel_data_variant1(current_frame, pixel, 0xFF, current_offset)
          current_offset += 1
          if (i*4 + 2) < count
            self.write_pixel_data_variant2(current_frame, pixel, 0xFF, current_offset)
            current_offset += 1
          end
        end
      else
        raise "invalid OPCODE #{opcode.to_s(16)}"
      end
    end
  end
end