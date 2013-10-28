require 'optparse'

def traverse(path,options)
	if FileTest.directory?(path)
		dir = Dir.open (path)

		#set serial number to 1 if the sn switch is on.
		#for folder may has multiple sub folders, 
		#set serial number to default when dive into 
		#a new folder

		options[:sn] = 1  if options[:sn] != nil

		while name=dir.read	
			next if name=="."
			next if name==".."
		
			traverse(path + "/" + name,options)
		
			options[:sn] += 1 if options[:sn] != nil
		end

		dir.close
	else
		process_file(path,options)
	end
end

def process_file(path,options)

	# the whole path for the file
	exp_path=File.expand_path(path) 

	# the extension of the file
	extname=File.extname(path)	

	# get the file name without extension
	filename=File.basename(path,".*")

	#replace file name to serial number if the sn switch is on
	filename=sprintf("%02d",(options[:sn])) if options[:sn] != nil

	current_path=File.dirname(path)

	prefix = (options[:prefix] == nil) ? "" : options[:prefix] + "_"
	suffix = (options[:suffix]	== nil) ? "" : "_" + options[:suffix]
	
	File.rename(exp_path,File.join(current_path,prefix + filename + suffix + extname))

	puts "File renamed from #{filename + extname} to #{prefix + filename + suffix + extname} "
end	

options={}

optparse = OptionParser.new do|opts|
   # Set banner of the program, displayed at the top
   # of the help screen.

   opts.banner = "Usage: MassRename [options]"
 
   # Define the options

   #switch
   options[:sn] = nil
   opts.on( '-n', '--serial-number', 'use serial number to replace the original Filename' ) do
     options[:sn] = 1
   end

   #flag
   options[:prefix] = nil
   opts.on( '-p', '--prefix string', 'Append prefix to Filename' ) do|prefixString|
     options[:prefix] = prefixString
   end

   options[:suffix] = nil
   opts.on( '-s', '--suffix string', 'Append suffix to Filename' ) do|suffixString|
     options[:suffix] = suffixString
   end

   options[:filepath] = nil
   opts.on( '-f', '--folder path', 'File or Folder path to be processed' ) do|path|
     options[:filepath] = path
   end
 
   # Display the help screen.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts
     puts opts
     exit
   end
 end

# Parse the command-line
optparse.parse!

if options[:filepath]==nil
	puts optparse
	exit(1)
end
  
if (options[:prefix]==nil && options[:suffix]==nil && options[:sn]==nil )
	puts optparse
	exit(1)
end
 

puts "set prefix to "  + options[:prefix] if options[:prefix]
puts "set suffix to "	 + options[:suffix] if options[:suffix]

sleep 2

puts
puts "Rename Start"
puts 

traverse(options[:filepath],options)

puts
puts "Done"
