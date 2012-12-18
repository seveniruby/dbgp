$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'dbgp'

params={}
opts=OptionParser.new do |opts|
	opts.banner = "
dbgp example
ruby dbgp.rb --help
ruby dbgp.rb -p 8072 #trace mode
ruby dbgp.rb -b breaks.data
ruby dbgp.rb -p 8072 -b breaks.data  #run mode
ruby dbgp.rb -p 8072 -b breaks.data  #run mode
ruby dbgp.rb -p 8072 -b breaks.data -s http://127.0.0.1:3000/testcase/1 #run mode
	"

	opts.on("-p:", "--port port", "port of debug server") do |v|
		params[:port] = v
	end

	opts.on("-b:", "--breakpoint file", "breakpoints file") do |v|
		params[:breakpoint_file] = v
	end
	opts.on("-m:", "--mode mode", "run mode, trace would record every line, run would record lines which defined by breakpoints file") do |v|
		params[:mode] = v
	end
	opts.on("-s:", "--server server", "post data to remote url") do |v|
		params[:server] = v
	end

end

opts.parse(ARGV)

include DBGP
session=GDBSession.new(params[:mode], params[:breakpoint_file],params[:server])
a = GDBServer.new(session, params[:port], host= '0.0.0.0',maxConnections = 100, stdlog = $stderr, audit = true, debug = true)
a.start
a.join
