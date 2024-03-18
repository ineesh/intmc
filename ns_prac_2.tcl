#comment out the telnet portion as it is not showing in nam animation

set ns [new Simulator]

set nf [open a.nam w]
$ns namtrace-all $nf

set tf [open a.tr w]
$ns trace-all $tf

proc finish { } {
 
	global ns nf tf
 	$ns flush-trace
 	close $nf
 	close $tf
 	exec nam a.nam &
 	exit 0
}

# defining 4 nodes
set a0 [$ns node]
set a1 [$ns node]
set a2 [$ns node]
set a3 [$ns node]

# setting up of bidirectional link between the following nodes and their positions
$ns duplex-link $a0 $a1 1.25Mb 10ms DropTail
$ns duplex-link $a1 $a2 1.25Mb 10ms DropTail
$ns duplex-link $a2 $a3 1.25Mb 10ms DropTail

#Creating orientation of the links between the nodes
$ns duplex-link-op $a0 $a1 orient right-down
$ns duplex-link-op $a1 $a2 orient right-up
$ns duplex-link-op $a2 $a3 orient right


$ns queue-limit $a0 $a1 5
$ns queue-limit $a1 $a2 5
$ns queue-limit $a2 $a3 5


# setting up TCP connection
set udp0 [new Agent/UDP]
#set tcp0 [new Agent/TCP]
#$ns attach-agent $a0 $tcp0
#set ftp0 [new Application/FTP]
$ns attach-agent $a0 $udp0
# setting up of traffic over TCP connection
#$ftp0 attach-agent $tcp0
#$ftp0 set packetSize_ 500
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 500

# setting up TCP connection
set tcp1 [new Agent/TCP]
$ns attach-agent $a1 $tcp1
set ftp1 [new Application/FTP]
# setting up of traffic over TCP connection
$ftp1 attach-agent $tcp1
$ftp1 set packetSize_ 500

# Setting up TCP Connection
set udp2 [new Agent/UDP]
$ns attach-agent $a2 $udp2
set telnet0 [new Application/Telnet]
#$telnet0 set interval_ 0.001
$telnet0 attach-agent $udp2

#$ns at 10.0 "$cbr1 stop"
#$telnet0 set type_ Telnet
#set ftp2 [new Application/FTP]
# setting up of traffic over TCP connection
#$ftp2 attach-agent $tcp2

set null0 [new Agent/TCPSink]
$ns attach-agent $a3 $null0
$ns connect $udp0 $null0
$ns connect $tcp1 $null0
#$ns connect $udp2 $null0

$ns at 1 "$cbr0 start"
$ns at 2 "$ftp1 start"
#$ns at 3 "$telnet0 start"

$ns at 10 "finish"

$ns run

