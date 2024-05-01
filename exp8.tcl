# Defining Node Configuration paramaters
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model 
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type 
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model 
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 8 ;# number of mobilenodes 
set val(rp) DSDV ;# routing protocol
set val(x) 400 ;# X dimension of the topography 
set val(y) 300 ;# Y dimensionof the topography


# Simulator Object
set ns [new Simulator]

# Trace file initialization
set tracef [open wireless3.tr w]
$ns trace-all $tracef

# Network Animator
set namf [open wireless3.nam w]
$ns namtrace-all-wireless $namf $val(x) $val(y)

# Topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y) 

#creation of god (General Operations Director) object 
create-god $val(nn)

set chan_1_ [new $val(chan)]

# configure nodes
$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace OFF \
		-routerTrace OFF \
		-macTrace OFF \
		-movementTrace OFF \
		-channel $chan_1_
		
		
# Create Nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns node]
    $node_($i) random-motion 0 ; # disable random motion
}

# Define node size in Network Animator 
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns initial_node_pos $node_($i) 20
}

#initial position of nodes
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 10.0
$node_(1) set Y_ 15.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 35.0
$node_(2) set Y_ 250.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 10.0
$node_(3) set Y_ 50.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 235.0
$node_(4) set Y_ 10.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 400.0
$node_(5) set Y_ 100.0
$node_(5) set Z_ 0.0

$node_(6) set X_ 285.0
$node_(6) set Y_ 150.0
$node_(6) set Z_ 0.0

$node_(7) set X_ 120.0
$node_(7) set Y_ 115.0
$node_(7) set Z_ 0.0


# simple node movements


$ns at 3.0 "$node_(1) setdest 50.0 40.0 25.0"
$ns at 3.0 "$node_(2) setdest 48.0 38.0 5.0"
$ns at 3.0 "$node_(5) setdest 50.0 40.0 25.0"
$ns at 3.0 "$node_(6) setdest 58.0 48.0 5.0"
$ns at 3.0 "$node_(7) setdest 248.0 78.0 5.0"

$ns at 20.0 "$node_(1) setdest 290.0 280.0 50.0" 
$ns at 20.0 "$node_(3) setdest 190.0 290.0 50.0" 
$ns at 20.0 "$node_(5) setdest 90.0 20.0 50.0" 
$ns at 20.0 "$node_(7) setdest 110.0 50.0 10.0" 

# Create traffic flow using TCP with Constant Bit Rate Application
# this includes priority and the sink is TCPSink agent to trace the bytes received (because the Null Agent does not handle this)
set agent1 [new Agent/TCP]
$agent1 set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $agent1
$ns attach-agent $node_(1) $sink
$ns connect $agent1 $sink
set app1 [new Application/FTP]
$app1 set packetSize_ 150
$app1 set interval_ 0.5
$app1 attach-agent $agent1 ; # attaching the agent
$ns at 3.0 "$app1 start" ;

set agent2 [new Agent/TCP]
$agent2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns attach-agent $node_(2) $agent2
$ns attach-agent $node_(5) $sink2
$ns connect $agent2 $sink2
set app2 [new Application/FTP]
$app2 set packetSize_ 150
$app2 set interval_ 0.5
$app2 attach-agent $agent2

# Start transmission at 2 Sec
$ns at 3.0 "$app2 start" ;

set agent3 [new Agent/TCP]
$agent3 set class_ 2
set sink3 [new Agent/TCPSink]
$ns attach-agent $node_(4) $agent3
$ns attach-agent $node_(3) $sink3
$ns connect $agent3 $sink3
set app3 [new Application/FTP]
$app3 set packetSize_ 150
$app3 set interval_ 0.5
$app3 attach-agent $agent3 

# Start transmission at 5 Sec
$ns at 3.0 "$app3 start" ;

set agent4 [new Agent/TCP]
$agent4 set class_ 2
set sink4 [new Agent/TCPSink]
$ns attach-agent $node_(6) $agent4
#$ns attach-agent $node_(7) $sink4
$ns connect $agent4 $sink2
set app4 [new Application/FTP]
$app4 set packetSize_ 150
$app4 set interval_ 0.5
$app4 attach-agent $agent4

# Start transmission at 15 Sec
$ns at 3.0 "$app4 start" ;

# Reset Nodes at time 80 sec
for {set i 0} {$i < $val(nn) } {incr i} {
	$ns at 30.0 "$node_($i) reset";
}


# Start transmission at 25 Sec
# Stop Simulation at Time 80 sec
$ns at 30.0 "finish"
$ns at 30.01 "puts \"NS EXITING...\" ; $ns halt"

proc finish {} {

	global ns tracef 	
		
	# Reset Trace File
	$ns flush-trace 
	close $tracef
	exec nam wireless3.nam &
	#exec awk -f exp8.awk wireless3.tr &
	
}

puts "Starting Simulation..."
$ns run
