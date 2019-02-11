$vms = Get-VM -Name isrv10dem2*
$snapname = "afterValidation"

foreach($vm in $vms){   
	 $snap = Get-Snapshot -VM $vm -Name $snapname
	Remove-Snapshot -SnapShot $snap -Confirm:$false
 }