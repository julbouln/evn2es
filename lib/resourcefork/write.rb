require 'iconv'

# TODO: Atomic writing?
class ResourceFork
	def write(io)
		Writer.new(self, io)
	end
	
protected
	class RW
		HEADER_SIZE = 64
		HEADER_PAD = HEADER_SIZE - 4 * 4
	
		MAP_HEADER_SIZE = MAP_HEADER_RESERVED + 6
		TYPELIST_HEADER_SIZE = 2
		TYPELIST_ENTRY_SIZE = 8
		REFLIST_ENTRY_SIZE = REFLIST_ENTRY_RESERVED + 8
	end
	
	class Writer < RW
		def initialize(rf, io)
			@io = io
			
			# Figure out some sizes and offsets, so we can write everything
			# in sequence
			typeEntries = rf.types.map do |t|
				TypeEntry.new(t, rf.type(t).size)
			end
			
			dataSize = nameSize = 0
			resEntries = rf.resources.map do |r|
				n = r.name && macRoman(r.name)
				re = ResourceEntry.new(r, dataSize, n ? nameSize : -1, n)
				dataSize += r.data.size + 4
				nameSize += n.size + 1 if n
				re
			end
			
			typeListSize = TYPELIST_HEADER_SIZE +
				typeEntries.size * TYPELIST_ENTRY_SIZE
			mapSize = MAP_HEADER_SIZE + typeListSize + 
				resEntries.size * REFLIST_ENTRY_SIZE + nameSize
		
			writeHeader(dataSize, mapSize)
			writeData(resEntries)
			writeMapHeader(rf, mapSize - nameSize)
			writeTypeList(typeEntries, typeListSize)
			writeRefList(resEntries)
			writeNameList(resEntries)
		end
		
		
		def writeInt(bytes, i)
			i += (1 << 32) if i < 0
			s = [i].pack('N')
			@io.write(s[4 - bytes, 4])
		end
		def write8(i); writeInt(1, i); end
		def write16(i); writeInt(2, i); end
		def write32(i); writeInt(4, i); end
		def writePad(bytes); @io.write("\0" * bytes); end
	
		def macRoman(s); Iconv.conv('MacRoman', 'UTF8', s); end
		def writeFCC(fcc); @io.write(macRoman(fcc)); end
		
		def writeAttributes(obj, bytes, attrList)
			i = 0
			attrList.reverse.each do |a|
				i = (i << 1) + (obj.__send__(a) ? 1 : 0)
			end
			writeInt(bytes, i << (bytes * 8 - attrList.size))
		end
		
		def writeHeader(dataSize, mapSize)
			write32(HEADER_SIZE)
			write32(HEADER_SIZE + dataSize)
			write32(dataSize)
			write32(mapSize)
			writePad(HEADER_PAD)
		end
		
		def writeData(resEntries)
			resEntries.each do |re|
				d = re.resource.data
				write32(d.size)
				@io.write(d)
			end
		end
		
		def writeMapHeader(rf, nameListOffset)
			writePad(MAP_HEADER_RESERVED)
			writeAttributes(rf, 2, ResourceFork::ATTRIBUTES)
			write16(MAP_HEADER_SIZE)
			write16(nameListOffset)
		end
		
		def writeTypeList(typeEntries, refListOffset)
			write16(typeEntries.size - 1)
			typeEntries.each do |te|
				writeFCC(te.type)
				write16(te.count - 1)
				write16(refListOffset)
				refListOffset += te.count * REFLIST_ENTRY_SIZE
			end
		end
		
		def writeRefList(resEntries)
			resEntries.each do |re|
				write16(re.resource.id)
				write16(re.nameOffset)
				writeAttributes(re.resource, 1, Resource::ATTRIBUTES)
				writeInt(3, re.dataOffset)
				writePad(REFLIST_ENTRY_RESERVED)
			end
		end
		
		def writeNameList(resEntries)
			resEntries.each do |re|
				next unless re.name
				write8(re.name.size)
				@io.write(re.name)
			end
		end
	end
end
