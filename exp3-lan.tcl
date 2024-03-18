# Make a NS simulator
LanRouter set debug_ 0
set ns [new Simulator]
set tf [open lab4.tr w]

$ns trace-all $tf
set nf [open lab4.nam w]
$ns namtrace-all $nf

# Create the nodes, color, and label
set n0 [$ns node]
$n0 color "magenta"
$n0 label "src1"

set n1 [$ns node]
$n1 color "red"

set n2 [$ns node]
$n2 color "red"
#$n2 label "src2"

set n3 [$ns node]
$n3 color "blue"
$n3 label "dest2"

set n4 [$ns node]
$n4 shape square

set n5 [$ns node]
$n5 shape square

set n6 [$ns node]
$n6 color "red"

set n7 [$ns node]
$n7 color "magenta"
$n2 label "src2"

set n8 [$ns node]
$n8 color "blue"
$n8 label "dest1"


$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns duplex-link $n3 $n4 1Mb 10ms DropTail
$ns duplex-link $n4 $n5 1Mb 10ms DropTail
$ns duplex-link $n5 $n6 1Mb 10ms DropTail
$ns duplex-link $n6 $n7 1Mb 10ms DropTail
$ns duplex-link $n7 $n8 1Mb 10ms DropTail


# Create LAN 1 with make-lan
set lan1 [$ns make-lan "$n0 $n1 $n2 $n3 $n4 $n5 $n6 $n7 $n8" 10Mb 10ms LL Queue/DropTail]
Mac/802_3 change

# Create LAN 2 with make-lan
#set lan2 [$ns make-lan "$n5 $n6 $n7 $n8" 10Mb 10ms LL Queue/DropTail]
#Mac/802_3 change

# Connect LAN 1 to LAN 2 with a duplex link
#set link_($n4:$n5) [$ns duplex-link $n4 $n5 5Mb 10ms DropTail]
#$ns duplex-link-op $n4 $n5 orient right-up

# Add a TCP sending module to node n0
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
# Setup a FTP traffic generator on "tcp0"
$tcp0 set window_ 10
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set packetSize_ 500
$ftp0 set interval_ 0.0001

# Add a TCP receiving module to node n5
set sink0 [new Agent/TCPSink]
$ns attach-agent $n8 $sink0

# Direct traffic from "tcp0" to "sink0"
$ns connect $tcp0 $sink0

# Add a TCP sending module to node n2
set tcp1 [new Agent/TCP]
$ns attach-agent $n7 $tcp1
$tcp1 set window_ 10
# Setup a FTP traffic generator on "tcp1"
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set packetSize_ 500
$ftp1 set interval_ 0.001

# Add a TCP receiving module to node n3
set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1
# Direct traffic from "tcp1" to "sink1"
$ns connect $tcp1 $sink1

set file1 [open file14.tr w]
$tcp0 attach $file1
set file2 [open file24.tr w]
$tcp1 attach $file2
$tcp0 trace cwnd_
$tcp1 trace cwnd_

$ns duplex-link-op $n0 $n1 orient right-up
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right-down
$ns duplex-link-op $n3 $n4 orient down
$ns duplex-link-op $n5 $n6 orient left
$ns duplex-link-op $n6 $n7 orient left-up
$ns duplex-link-op $n7 $n8 orient left

# Define a 'finish' procedure
proc finish { } {
    global ns nf tf
    $ns flush-trace
    close $tf
    close $nf
    exec nam lab4.nam &
    # Generate xgraph for file14.tr with red color
	#exec xgraph -color red file14.tr &
	exec awk -f exp4.awk file14.tr > a1 & 

	# Generate xgraph for file24.tr with blue color
	exec awk -f exp4.awk file24.tr > a2 &
	#exec xgraph -color blue file24.tr &
	
	exec xgraph a1 a2 &
    exit 0
}

# Schedule start/stop times
$ns at 0.1 "$ftp0 start"
$ns at 2 "$ftp0 stop"
$ns at 3 "$ftp1 start"
$ns at 8 "$ftp1 stop"
$ns at 9 "$ftp0 start"
$ns at 10 "$ftp1 start"
$ns at 14 "$ftp0 stop"
$ns at 15 "$ftp1 stop"

# Set simulation end time
$ns at 16 "finish"
$ns run
