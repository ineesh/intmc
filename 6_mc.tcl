
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11               ;# MAC type can change to 802_11
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             5                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
#set val(rp)             DSR                       ;# routing protocol
set val(x)		400
set val(y)		300

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open 6_exp.tr w]
$ns_ trace-all $tracefd

set namtrace [open 6_exp.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)



# Create channel #1 and #2
set chan_1_ [new $val(chan)]
#set chan_2_ [new $val(chan)]

# Create node(0) "attached" to channel #1

# configure node, please note the change below.
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace ON \
		-channel $chan_1_ 

set node_(0) [$ns_ node]
set node_(1) [$ns_ node]
set node_(2) [$ns_ node]
set node_(3) [$ns_ node]
set node_(4) [$ns_ node]

$node_(0) random-motion 1
$node_(1) random-motion 1
$node_(2) random-motion 1
$node_(3) random-motion 1
$node_(4) random-motion 1

# Set initial positions for all nodes
# Set initial positions for all nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    # Set the size of the initial area for positioning nodes
    set size 20
    # Calculate the position of each node within the area
    #set x_coord [expr {rand()*$size}]
    #set y_coord [expr {rand()*$size}]
    #set z_coord 0  

    # Set initial position for the node
    $ns_ initial_node_pos $node_($i) $size
}


#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 15.0
$node_(0) set Y_ 12.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 28.0
$node_(1) set Y_ 25.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 37.0
$node_(2) set Y_ 33.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 49.0
$node_(3) set Y_ 46.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 52.0
$node_(4) set Y_ 67.0
$node_(4) set Z_ 0.0





# simple node movements


$ns_ at 3.0 "$node_(1) setdest 50.0 40.0 25.0"
$ns_ at 3.0 "$node_(0) setdest 48.0 38.0 5.0"
$ns_ at 3.0 "$node_(2) setdest 50.0 40.0 25.0"
$ns_ at 3.0 "$node_(3) setdest 58.0 48.0 5.0"
$ns_ at 3.0 "$node_(4) setdest 248.0 78.0 5.0"



$ns_ at 20.0 "$node_(1) setdest 290.0 280.0 50.0" 
$ns_ at 20.0 "$node_(2) setdest 190.0 290.0 50.0" 
$ns_ at 20.0 "$node_(4) setdest 90.0 20.0 50.0" 

# Setup traffic flow between nodes


set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $node_(1) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at 3.0 "$ftp1 start" 


# TCP connections between node_(2) and node_(3)

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(2) $tcp2
$ns_ attach-agent $node_(3) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at 3.0 "$ftp2 start" 


# TCP connections between node_(4) and node_(3)

set tcp3 [new Agent/TCP]
$tcp3 set class_ 2
$ns_ attach-agent $node_(4) $tcp3
$ns_ connect $tcp3 $sink2
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ns_ at 3.0 "$ftp3 start" 


# Tell nodes when the simulation ends

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 30.0 "$node_($i) reset";
}
$ns_ at 30.0 "stop"
$ns_ at 30.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
    exec nam 6_exp.nam &
    exec awk -f met.awk 6_exp.tr & 
}

puts "Starting Simulation..."
$ns_ run



