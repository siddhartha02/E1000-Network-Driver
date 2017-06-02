#include "ns.h"

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	cprintf("NS OUTPUT ENV is on!\n");

	// Virtual address at which to receive page mappings containing requests
	
	union Nsipc *nsipc = (union Nsipc *)0x0ffff000;
	envid_t whom; 	int perm;     
	// Endless loop s
	while (1) {
		uint32_t req = ipc_recv(&whom, nsipc, &perm);

		// Check if the request is of the expected type
		if (req == NSREQ_OUTPUT) {
			// read request packet data
			int size = (nsipc->pkt).jp_len;
			char *buf = (nsipc->pkt).jp_data;

			
			// Transmit the packet
			int r;
			if ((r = sys_transmit_packet(buf, size)) < 0)
				panic("sys_transmit_packet: %e", r);
		} else {
			panic("NS OUTPUT ENV: Invalid request received!");
		}
	}
}
