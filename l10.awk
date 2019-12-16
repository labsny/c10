BEGIN {
rcvdsize=0;
start=400;
stop=0;
}
{
event = $1;
time = $2;
pkt_sz = $8;
level = $4;

if(level == "AGT" && event == "s" && pkt_sz>=512) {
	if(time < start){
		start = time
	}
}
if(level == "AGT" && event == "r" && pkt_sz>=512) {
	if(time > stop){
		stop = time
	}
	
	hdr_size = pkt_sz%512
	pkt_sz -= hdr_size
	rcvdsize += pkt_sz
}
}
END {
printf("Recievd %.2f start %.2f stop %.2f",rcvdsize,start,stop);
printf("Avg throughput[kbps]= %.2f\n",(rcvdsize/(stop-start))*(8/1000));
}
