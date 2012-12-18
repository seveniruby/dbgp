echo test trace
#测试trace模式
ruby ../bin/dbgp.rb &
pid=$!
sleep 3
php -c php.ini trace.php xdebugxdebuga
kill $pid


