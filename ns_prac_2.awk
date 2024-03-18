BEGIN {
	dropped=0;
	received=0;
}

{
	event=$1;
	
	if(event == "d"){
		dropped++;
	}
	
	if(event == "r"){
		received++;
	}
}

END {
		printf("The no.of packets dropped : %d\n ",dropped);
		printf("The no.of packets recieved : %d\n ",received);
}

