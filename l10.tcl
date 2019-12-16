set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 50
set val(nn) 3
set val(rp) AODV
set val(x) 500
set val(y) 400
set val(stop) 40


set ns [new Simulator]
set tf [open l10.tr w]
$ns trace-all $tf

set nf [open l10.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

set cwind [open win10.tr w]

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-IncomingErrorProc "uniformErr" \
-OutgoingErrProc "uniformErr"

proc uniformErr {} {
set err [new ErrorModel]
$err unit pkt
$err set rate_ 0.1
return $err
}

for {set i 0} {$i<$val(nn)} {incr i} {
 set node_($i) [$ns node]
 $node_($i) random-motion 0
}

$node_(0) set X_ 100.0
$node_(0) set Y_ 110.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 200.0
$node_(1) set Y_ 210.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 300.0
$node_(2) set Y_ 310.0
$node_(2) set Z_ 0.0


for {set i 0} {$i<$val(nn)} {incr i} {
$ns initial_node_pos $node_($i) 40
}

$ns at 0.0 "$node_(0) setdest 300.0 310.0 3.0"
$ns at 0.0 "$node_(1) setdest 300.0 310.0 3.0"
$ns at 0.0 "$node_(2) setdest 100.0 110.0 4.0"


$ns at 15.1 "$node_(0) setdest 50.0 60.0 3.0"
$ns at 15.1 "$node_(2) setdest 300.0 310.0 5.0"


set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp0
$ns attach-agent $node_(2) $sink0
$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 10.0 "$ftp0 start"
#$ns at 10.0 "$ftp0 stop"

proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [ $tcpSource set cwnd_ ]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}

$ns at 1.0 "plotWindow $tcp0 $cwind"

proc finish {} {
global ns tf nf cwind
$ns flush-trace
close $tf
close $nf
close $cwind
exec nam l10.nam &
#exec xgraph wintrace.tr &
exit 0
}

for {set i 0} {$i<$val(nn)} {incr i} {
$ns at $val(stop) "$node_($i) reset";
}

$ns at $val(stop) "puts \"NS EXITING ...\"; $ns halt"
puts "Starting Simulation ... "

$ns run
