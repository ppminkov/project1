$vms = Get-VM -Name isrv10vra2*
$snapname = "AfterMigDrop_3_1"
$date = Get-Date -format u
$snapdesc = "Done: pminkov and before revert to one node to upgrade for drop3_2"
  
#Create Snapshot
$vms | New-Snapshot -Name $snapname -Description $snapdesc
