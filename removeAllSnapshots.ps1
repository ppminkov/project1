$vms = Get-VM -Name dsrv10vra2*

foreach($vm in $vms){   
	 $snap = $vm | Get-Snapshot | Remove-Snapshot -confirm:$false -RemoveChildren
 }