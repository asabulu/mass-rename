require 'optparse'

def traverse(path,options)
	if FileTest.directory?(path)
		dir = Dir.open (path)

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

	exp_path=File.expand_path(path) # the whole path for the file

	extname=File.extname(path)	

	filename=File.basename(path,".*")

	#replace file name to serial number

	filename=sprintf("%02d",(options[:sn])) if options[:sn] != nil

	current_path=File.dirname(path)

	prefix = (options[:prefix] == nil) ? "" : options[:prefix] + "_"
	suffix = (options[:suffix]	== nil) ? "" : "_" + options[:suffix]
	
	File.rename(exp_path,File.join(current_path,prefix + filename + suffix + extname))

	puts "File renamed from #{filename + extname} to #{prefix + filename + suffix + extname} "
end	

options={}

optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: MassRename [options]"
 
   # Define the options, and what they do
   options[:sn] = nil
   opts.on( '-n', '--serial-number', 'use serial number to replace the original Filename' ) do
     options[:sn] = 1
   end

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
 
   # This displays the help screen, all programs are
   # assumed to have this option.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts
     puts opts
     exit
   end
 end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

#puts options[:prefix] if options[:prefix]
#puts options[:suffix] if options[:suffix]
#puts options[:logfile] if options[:logfile]
  
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
