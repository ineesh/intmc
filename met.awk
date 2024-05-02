# Initialize variables
BEGIN {
    total_delay = 0
    total_packets_sent = 0
    total_packets_received = 0
}

# Process each line of the trace file
{
    print "Processing line:", $0  # Debug statement

    if ($1 == "s" && $4 == "AGT" && $7 == "cbr" && $8 == "32" && $11 == "[0" && $12 == "0" && $13 == "0" && $14 == "0]" && $15 == "[1" && $16 == "2]" && $17 == "0") {
        # Calculate end-to-end delay
        end_to_end_delay = $2 - $0
        total_delay += end_to_end_delay

        # Increment total packets sent
        total_packets_sent++
    }

    if ($1 == "r" && $4 == "AGT" && $7 == "cbr" && $8 == "32" && $11 == "[0" && $12 == "0" && $13 == "0" && $14 == "0]" && $15 == "[1" && $16 == "2]" && $17 == "0") {
        # Increment total packets received
        total_packets_received++
    }
}

# Calculate throughput
END {
    print "Total delay:", total_delay  # Debug statement
    print "Total packets sent:", total_packets_sent  # Debug statement
    print "Total packets received:", total_packets_received  # Debug statement

    # Calculate average end-to-end delay
    if (total_packets_received > 0) {
        average_delay = total_delay / total_packets_received
    } else {
        average_delay = 0
    }

    # Calculate throughput (assuming packet size is 500 bytes)
    throughput = (total_packets_received * 500 * 8) / 1e6  # Convert to Mbps

    # Calculate packet delivery ratio
    if (total_packets_sent > 0) {
        packet_delivery_ratio = total_packets_received / total_packets_sent
    } else {
        packet_delivery_ratio = 0
    }

    # Print results
    printf("Average End-to-End Delay: %.2f ms\n", average_delay)
    printf("Throughput: %.2f Mbps\n", throughput)
    printf("Packet Delivery Ratio: %.2f\n", packet_delivery_ratio)
}

