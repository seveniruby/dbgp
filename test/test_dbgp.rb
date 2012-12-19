require 'test/unit'
require '../lib/dbgp.rb'
include DBGP
class DBGPTest  < Test::Unit::TestCase
	def setup
	end
	def teardown
		sleep 5
	end
	def test_trace
		@session=GDBSession.new(nil,nil)
		@server = GDBServer.new(@session, 8072, host= '0.0.0.0',maxConnections = 100, stdlog = $stderr, audit = true )
		@server.start
		@session.tc_set('trace')
		`php -c php.ini trace.php xdebugxdebuga`
		@server.stop
		res=@session.tc_get('trace')
		p res.count
		assert_equal true, res.count>41
		# this test should succeed
	end
	def test_run
		@session=GDBSession.new('breaks.data',nil)
		@server = GDBServer.new(@session, 8072, host= '0.0.0.0',maxConnections = 100, stdlog = $stderr, audit = true )
		@server.start
		@session.tc_set('run')
		`php -c php.ini trace.php xdebugxdebuga`
		@server.stop
		res=@session.tc_get('run')
		p res.count
		assert_equal true, res.count==41
		# this test should succeed
	end

end

