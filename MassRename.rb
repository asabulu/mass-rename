require 'optparse'

def traverse(path,options)
	if FileTest.directory?(path)
		dir = Dir.open (path)

		#set serial number to 1 if the sn switch is on.
		#for folder may has multiple sub folders, 
		#set serial number to default when dive into 
		#a new folder

		options[:sn] = 1  if options[:sn] != nil

		$filesProcessed=[]

		while name=dir.read	
			next if name=="."
			next if name==".."
		
			filename=File.basename(path + "/" + name,".*")

			if options[:sn] != nil
      	if options[:reuse]==true
      		if $filesProcessed.size==0
      			$filesProcessed.push(filename)
      		else
      				if !$filesProcessed.include?(filename)
      					$filesProcessed.push(filename)
      			  	options[:sn] += 1 
      			  end  
      		end	
      	#else
      	#	options[:sn] += 1
      	end 		
      end		

			traverse(path + "/" + name,options)

			options[:sn] += 1 if ((options[:sn] != nil) && (options[:reuse]==nil))


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

	#replace file name to serial number if the sn switch is on and mode is replace
	snfilename=filename 
	
	if options[:sn] != nil

		snfilename=sprintf("%02d",(options[:sn])) if options[:mode] == "r"
		snfilename=filename + "_" + sprintf("%02d",(options[:sn])) if options[:mode] == "a"
	
	end 	

	current_path=File.dirname(path)

	prefix = (options[:prefix] == nil) ? "" : options[:prefix] + "_"
	suffix = (options[:suffix]	== nil) ? "" : "_" + options[:suffix]
	
	File.rename(exp_path,File.join(current_path,prefix + snfilename + suffix + extname))

	puts "File renamed from #{filename + extname} to #{prefix + snfilename + suffix + extname} "
end	

options={}

optparse = OptionParser.new do|opts|
   # Set banner of the program, displayed at the top
   # of the screen.

   opts.banner = "Usage: MassRename [options]"
 
   # Define the options

   #switch
   options[:sn] = nil
   opts.on( '-n', '--serial-number', 'use serial number to replace or append to the original Filename' ) do
     options[:sn] = 1
   end

   options[:reuse] = nil
   opts.on( '-r', '--serial-number-reuse', 'reuse serial number for same Filename within a folder' ) do
     options[:reuse] = true
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
 
 	 options[:mode] = nil
   opts.on( '-m', '--serial-number-mode mode', 'Use serial number to append to or replace the Filename [a|r] . Append is the default mode.' ) do|mode|
     options[:mode] = mode
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

#files processed array
$filesProcessed=[]

if options[:filepath]==nil
	puts optparse
	exit(1)
end
  
if (options[:prefix]==nil && options[:suffix]==nil && options[:sn]==nil )
	puts optparse
	exit(1)
end

if (options[:sn] !=nil)
	
	options[:mode] ||= "a"
	
	modeAvaliable=%w(a r)

	if modeAvaliable.include?(options[:mode])

	else
		 puts optparse
		 exit(1)
	end	
	
end
 

puts "set prefix to "  + options[:prefix] if options[:prefix]
puts "set suffix to "	 + options[:suffix] if options[:suffix]
puts "set reuse serial number for same file name feature on" if options[:reuse] !=nil

if options[:sn] != nil
	puts "use serial number to #{options[:mode]=='a'?'append to':'replace'} the file name"
end 

sleep 2

puts
puts "Rename Start"
puts 

traverse(options[:filepath],options)

puts
puts "Done"
