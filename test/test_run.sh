echo test run
#测试run模式
ruby ../bin/dbgp.rb -b breaks.data  &
pid=$!
sleep 3
php -c php.ini trace.php xdebugxdebuga
kill $pid


