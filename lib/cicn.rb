# https://github.com/fuzziqersoftware/resource_dasm/blob/master/resource_fork.cc
require 'nova/raw/extra'
class Cicn

  def self.decode(cicn)
    header = Nova::Raw::CicnHeader.read(cicn)
    mask_size = header.mask_row_bytes*header.mask_h
    mask_data = cicn[header.num_bytes..(header.num_bytes+mask_size)]
    bitmap_size = header.bitmap_row_bytes*header.bitmap_h
    bitmap_data = cicn[(header.num_bytes+mask_size)..(header.num_bytes+mask_size+bitmap_size)]
    puts header
  end
end