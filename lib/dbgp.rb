#encoding: utf-8
require 'rubygems'
#require "bundler/setup"
require 'gserver'
require 'xmlsimple'
require 'base64'
require 'pp'
require 'restclient'
require 'json'
require 'yaml'
require 'optparse'

module DBGP
	class GDBServer < GServer
		def initialize(session,port, *args)
			@session=session
			port=8072 if !port
			super(port, *args)
		end


		def serve(io)
			begin
				@session.start(io)
			rescue Exception=>e
				p e.message
				p e.backtrace
				puts e.to_s
			end
		end

	end

	class GDBSession
		def initialize(breakpoint_file,server)
			if breakpoint_file
				@mode='run'
			else
				@mode='trace'
			end
			@breakpoint_file = breakpoint_file
			@server=server
			@threads=[]
			#存放一次调试的所有记录
			@res_list||={}
			@testcase_name||="all"
			@res_list[@testcase_name]=[]
			@content=[]
			@breakpoints={}

			
		end

		def breakpoints_set
			if @breakpoint_file
				if File.exist? @breakpoint_file
					IO.readlines(@breakpoint_file).each do |line|
						data=line.split
						next if !data[0]
						run_cmd "breakpoint_set -i 1 -t line -f #{data[0]} -n #{data[1]}"
						@breakpoints["#{data[0]}:#{data[1]}"]=data[2]
					end
				end
			else
				p 'no breakpoints set'
			end
		end

		def send_cmd(cmd,arg)

		end

		def evaluate(line)
			@io.write("#{line}\0")
		end

		def print_response
			data = @io.readpartial(40960)
			data1=data.split("\n")[1..-1].join("\n").gsub("\0",'')
			hash=XmlSimple.xml_in(data1)
			hash
		end

		def has_response?
			IO.select([@io], nil, nil, 0.01)
		end

		def closed?
			if @io.closed?
				@io.close
				return true
			else
				return false
			end
		end

		def get_var
			cmd="context_get -i #{Time.now}" 

		end
		def run_cmd(cmd)
			evaluate(cmd)
			res=nil
			loop do
				if has_response?
					res=print_response				
					break
				end

				if closed?
					break
				end
			end
			res
		end

		def step_into
			@step_index||=0
			res=run_cmd("step_into -i #{@step_index}")
			@step_index+=1
			res
		end

		def context_get
			run_cmd("context_get -i 2")
		end

		def source_get(line)
			run_cmd("source -b #{line} -e #{line} -i 5")
		end

		def stack_get
			run_cmd("stack_get -i 4")
		end

		def eval(cmd)
			run_cmd("eval -i 3 -- #{Base64.encode64(cmd)}")
		end

		def file_get(file)
			res=self.eval "file_get_contents(\"#{file}\");"
			res
		end

		def step

			res=step_into

			return nil if !res
			return nil if res["status"]=="stopping"

		end

		def data_get
			data={}
			res=stack_get
			data[:file]=res["stack"][0]["filename"].split('/')[-1]
			data[:line]=res["stack"][0]["lineno"].to_i
			data[:name]=@breakpoints["#{data[:file]}:#{data[:line]}"]
			data[:stack]=res["stack"].reverse.map{|x| "#{x['where']}:#{x['lineno']}"}.join('->')


			res=source_get data[:line]
			return nil if !res
			return nil if res["status"]=="stopping"

			begin
				data[:code]=Base64.decode64(res['content']).encode('UTF-8', :invalid=>:replace, :undef=>:replace, :replace=>"?") if res['content']
			rescue Exception=>e
			end

=begin
		res=context_get
		return nil if !res
		return nil if res["status"]=="stopping"
		data[:data]=res["property"] #.map{|x| {x['fullname']=>Base64.decode64(x['content'])}}

=end
			p data
			data
		end


		def run()

			while true do
				res=run_cmd 'run -i 1'
				if !res || res['status']=='stopping'
					break;
				end
				data=data_get
				@res_list[@testcase_name]<<data
			       p @testcase_name	
			end
			nodes_send
		end

		def trace()		
			while true do
				res=step_into
				if !res || res['status']=='stopping'
					break;
				end
				data=data_get
				@res_list[@testcase_name]<<data 
			end
			nodes_send
		end

		def start(io)
			@io=io
			if has_response?
				res=print_response
				res=file_get res["fileuri"].gsub(/.*\//,'')	
				@content=Base64.decode64 res["property"][0]["content"]
			end
			breakpoints_set
			if @mode=='run'
				run
			else
				trace
			end
		end

		def data
			@res_list
		end

		def tc_set(name)
			@testcase_name=name
			@res_list[@testcase_name]||=[]

		end
		def tc_clear
			@res_list[@testcase_name]=[]
		end
		def tc_get(name="all")
			p @res_list.keys
			@res_list[name]
		end

		def nodes_send
			return if !@res_list
			puts "records number = #{@res_list[@testcase_name].count}"
			File.open(Time.now.to_i.to_s+'.yaml','w') do |f|
				f.puts @res_list.to_yaml
			end

			if @server		
				RestClient.post $server, :res=>@res_list.to_json, :ip=>@io.peeraddr[-1].to_s, :content_type => 'text/json'
			end
		end

	end
end
