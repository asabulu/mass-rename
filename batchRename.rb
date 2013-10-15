prefix = ARGV[0]
path= ARGV[1]

def traverse(path,prefix)
	if FileTest.directory?(path)
		dir = Dir.open (path)

		while name=dir.read	
			next if name=="."
			next if name==".."
			traverse(path + "/" + name,prefix)
		end
		dir.close
	else
		process_file(path)
	end
end

def process_file(path,prefix)
	File.rename(path,prefix + "_" + path)
end	