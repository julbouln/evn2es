require 'iconv'

class ResourceFork
protected
	class RW
		TypeEntry = Struct.new(:type, :count)
		ResourceEntry = Struct.new(:resource, :dataOffset, :nameOffset, :name)
	
		MAP_HEADER_RESERVED = 22
		REFLIST_ENTRY_RESERVED = 4
	end
	
	class Reader < RW
		def initialize(rf, io, outResources)
			@io = io
			
			seek 0	# fork header
			dataOffset, mapOffset = readU32, readU32
			
			seek mapOffset + MAP_HEADER_RESERVED	# map header
			readAttributes(rf, 2, ResourceFork::ATTRIBUTES)
			typeOffset, nameOffset = readU16, readU16
			
			typeEntries = readTypeList
			resEntries = readRefLists(outResources, typeEntries,
				mapOffset + nameOffset, dataOffset)
			readNameList(resEntries)
			readData(resEntries)
		
			# Hook 'em up to the fork
			resEntries.each do |re|
				re.resource.instance_variable_set(:@fork, rf)
			end
		end
		
		def seek(offset)
			@io.seek(offset) if @io.pos != offset
			@io.eof? and raise EOFError
		end

		def readBytes(bytes)
			data = @io.read(bytes)
			data.size == bytes or raise EOFError
			data
		end
		def readUnsigned(bytes)
			i = 0
			readBytes(bytes).each_byte { |b| i = (i << 8) + b }
			return i
		end
		def readSigned(bytes)
			bits = 8 * bytes
			i = readUnsigned(bytes)
			i > (1 << (bits - 1)) ? i - (1 << bits) : i
		end
		def readU8; readUnsigned(1); end
		def readU16; readUnsigned(2); end
		def readU32; readUnsigned(4); end
	
		def macRoman2UTF8(s); Iconv.conv('UTF8', 'MAC', s); end
		def readFCC; macRoman2UTF8(readBytes(4)); end
		def readPstring; macRoman2UTF8(readBytes(readU8)); end
	
		def readAttributes(obj, bytes, attrList)
			attrData = readUnsigned(bytes)
			attrData >>= bytes * 8 - attrList.size
			attrList.each do |a|
				obj.__send__("#{a}=", attrData & 1 == 1)
				attrData >>= 1
			end
		end
		
		def readTypeList
			entries = []
			(readU16 + 1).times do
				t, cntM1, off = readFCC, readU16, readU16
				entries << TypeEntry.new(t, cntM1 + 1)
			end
			return entries
		end
	
		def readRefLists(outResources, typeEntries, absNameOff, dataOff)
			entries = []
			typeEntries.each do |te|
				rh = outResources[te.type] = {}
				te.count.times do
					id, noff = readU16, readSigned(2)
					r = Resource.new(te.type, id)
					readAttributes(r, 1, Resource::ATTRIBUTES)
					doff = readUnsigned(3)
					readBytes(REFLIST_ENTRY_RESERVED)
					
					rh[id] = r
					entries << ResourceEntry.new(r, dataOff + doff,
						noff == -1 ? nil : absNameOff + noff, nil)
				end
			end
			return entries
		end
	
		def readNameList(resEntries)		
			res = resEntries.select { |re| re.nameOffset }
			res.sort_by { |re| re.nameOffset }.each do |re|
				seek re.nameOffset # should be unnecessary, no harm though
				re.resource.name = readPstring
			end
		end
	
		def readData(resEntries)
			resEntries.sort_by { |re| re.dataOffset }.each do |re|
				seek re.dataOffset
				len = readU32
				re.resource.data = readBytes(len)
			end
		end
	end
end
