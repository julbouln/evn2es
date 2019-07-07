require 'resourcefork/read'
require 'resourcefork/write'

class ResourceFork
	ATTRIBUTES = [:changed, :compact, :readonly]
	attr_accessor *ATTRIBUTES
	def attributes; ATTRIBUTES.select { |a| __send__(a) }; end
	
	class Resource
		ATTRIBUTES = [:changed, :preload, :protected, :locked,
			:purgeable, :sysheap, :sysref]
		attr_accessor *ATTRIBUTES
		def attributes; ATTRIBUTES.select { |a| __send__(a) }; end
		
		# TODO: Freeze type, id?
		attr_accessor :name, :data
		attr_reader :type, :id
				
		def initialize(type, id, name = nil, data = '', *attrs)
			ATTRIBUTES.each { |a| __send__("#{a}=", false) }
			@type, @id, @name, @data = type, id, name, data
			@fork = nil
		end
	end
	
	# TODO: filename
	def initialize(io)
		ATTRIBUTES.each { |a| self.__send__("#{a}=", false) }
		@resources = {} # indexed by type, then id
		Reader.new(self, io, @resources)
		
		# TODO: write; write on close?
	end
	
	# TODO: Cache sort?
	def types; @resources.keys.sort; end
	def type(type)
		rs = @resources[type] or return nil
		rs.values.sort_by { |r| r.id }
	end
	def resource(type, id)
		rs = @resources[type] or return nil
		rs[id]
	end
	def resources
		types.inject([]) { |a,t| a.concat(type(t)) }
	end
end

if __FILE__ == $0
	f1, f2 = *ARGV
	rf = ResourceFork.new(open(f1))
	if f2
		rf.write(open(f2, 'w'))
	else
		puts rf.attributes.join(' ') unless rf.attributes.empty?
		rf.resources.each do |r|
			line = "%4s  %5d" % [r.type, r.id]
			line += " '#{r.name}'" if r.name
			line += ' ' + r.attributes.join(' ') unless r.attributes.empty?
			puts line
		end
	end
end
