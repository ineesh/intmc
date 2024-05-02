# Initialize variables
BEGIN {
    control_pac = 0
    collision_pac = 0
}

# Process each line in the trace file
{
    # Check if the line represents a packet transmission event
    if ($4 == "RTR") {
        # Extract relevant information
        # Increment total control packets
        control_pac++
    }
    
    # Check if the line represents a packet reception event
    if ($5 == "COL") {
        # Extract relevant information
        # Increment total collision packets
        collision_pac++
    }
}

# Calculate and print metrics
END {
    # Print metrics
    print "Control Packets:", control_pac
    print "Collision Packets:", collision_pac
}

