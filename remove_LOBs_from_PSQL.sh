#!/bin/bash
runlog=/storage/log/vmware/`/bin/date "+%Y%m%dT%H%M"`_remove_lo.log
vaclog=/storage/log/vmware/`/bin/date "+%Y%m%dT%H%M"`_vacuum.log

function removelo {
echo `/bin/date "+%Y-%m-%dT%H:%M:%S"` starting removelo >> $runlog
/opt/vmware/vpostgres/current/bin/vacuumlo -v vcac  -U postgres  >$runlog 2>&1
echo `/bin/date "+%Y-%m-%dT%H:%M:%S"` Finish removelo >> $runlog
}

function do_vacuum {
echo `/bin/date "+%Y-%m-%dT%H:%M:%S"` starting vacuum >> $vaclog
/opt/vmware/vpostgres/current/bin/vacuumdb -v vcac  -U postgres >$vaclog 2>&1
echo `/bin/date "+%Y-%m-%dT%H:%M:%S"` Finish vacuum >> $vaclog
}

# execute functions as Main Program
removelo
do_vacuum
