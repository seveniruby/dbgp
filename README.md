dbgp
====

用于php远程调试，利用xdebug的remote debug功能。使用前先配置php.ini文件，增加如下配置

[Xdebug] <br>
zend_extension_ts="C:\Program Files\PHP\ext\php_xdebug.dll" <br>
xdebug.remote_enable=on <br>
xdebug.remote_autostart=1 <br>
xdebug.profiler_enable=on <br>
xdebug.remote_host=localhost <br>
xdebug.remote_port=8072 <br>

此时php的文件运行，就可以产生一个到设定ip与port的调试连接。dbgp gem利用此连接，自动接管调试，并记录运行过程的一些数据。
包括堆栈，代码，代码行，以及可能的数据。

运行模式支持trace与run模式。
trace模式记录所有的运行数据。
run模式根据设定好的断点数据，只记录断点数据的内容。用于提高速度。

可单独执行ruby bin/dbgp.rb运行
也可以加载gem，从而在自己的其他脚本中运行。
也可以使用纯java的实现

此工具是百度听风者测试平台的子部分。
