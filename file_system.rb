Dir.each_child("/Users/geekoncoffee/Desktop/examples") { |child| puts 'File: ' + child }

path = File.join(Dir.home, ".foo")
unless Dir.exist? path
  Dir.mkdir(path, 0700) #=> 0
end

log_file = File.join(path, "log")
File.open(log_file, "a") do |file|
  file.write "#{Time.now} - #{ENV['USERNAME'] || ENV['USER']} logged in\n"
end

puts File.read(log_file)

puts "Last Accessed: #{File.stat(log_file).atime}"
puts "Blocksize: #{File.stat(log_file).blksize}"
puts "Permissions: #{sprintf("%o", File.stat(log_file).mode)}"