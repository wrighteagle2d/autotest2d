#!/bin/bash

echo "Content-type: text/html"
echo ""

/bin/cat << EOM
<HTML>
<HEAD><TITLE>Auto-test Results Page</TITLE>
</HEAD>
<BODY bgcolor="#cccccc" text="#000000">
<HR SIZE=5>
<H1>Auto-test Results Page</H1>
<HR SIZE=5>
<P>
<SMALL>
<PRE>
EOM

cd /home/baj/autotest-ms
./result.sh

/bin/cat << EOM
<HR SIZE=5>
EOM

./analyze -b

/bin/cat << EOM
<p>
<img src="http://192.168.26.3/pp.png">
</p>
</PRE>
</SMALL>
<P>
</BODY>
</HTML>
EOM
