#!/usr/bin/ruby
# (C) Dave Vasilevsky 2011
# BSD Licensed: http://www.opensource.org/licenses/bsd-license.php

class AppleDouble
	# Format from http://www.rfc-editor.org/rfc/rfc1740.txt
	
	MagicSingle = 0x00051600
	MagicDouble = 0x00051607
	
	EntryTypes = %w[DataFork ResourceFork MacName Comment IconBW
		IconColor x FileDates FinderInfo MacInfo ProDOSInfo MSDOSInfo
		ShortName AFPInfo DirectoryID]
	
	def initialize(file, &block)
		begin
			@fh = file.respond_to?(:read) ? file : open(file)
			
			magic = @fh.read(4).unpack('N').first
			raise "Not an AppleSingle/Double file" \
				unless [MagicSingle, MagicDouble].include?(magic)
			vers = @fh.read(4).unpack('N').first
			raise "Unknown version" \
				unless [0x10000, 0x20000].include?(vers)
			fsname, nentries = @fh.read(18).unpack('A16n')
			
			@entries = {}
			nentries.times do
				tnum, off, len = @fh.read(12).unpack('N3')
				type = EntryTypes[tnum-1].to_sym
				@entries[type] = [off, len]
			end
			
			block[self] if block
		ensure
			self.close if block
		end
	end
	
	def self.canon(type)
		t = type.respond_to?(:upcase) &&
			EntryTypes.find { |x| x.upcase == type.upcase }
		t ||= type.respond_to?(:to_i) && EntryTypes[type.to_i - 1]
		t && t.to_sym
	end
	
	def get(type)
		type = self.class.canon(type)
		off, len = @entries[type]
		raise "Type #{type} not present" unless off
		@fh.seek(off)
		@fh.read(len)
	end
	
	def types; @entries.keys.sort_by { |x| x.to_s }; end
	def has?(type); @entries[self.class.canon(type)]; end
	def close; @fh.close; end
end

if __FILE__ == $0
	raise "No file given" if ARGV.empty?
	AppleDouble.new(ARGV.shift) do |f|
		if type = ARGV.shift
			print f.get(type)
		else
			puts f.types.join(' ') # just list contents
		end
	end
end
