#include <inc/memlayout.h>
#include <inc/error.h>
#include <inc/string.h>

#include <kern/e1000.h>
#include <kern/pmap.h>

volatile uint32_t *e1000; // Pointer to the start of E1000's MMIO region
uint8_t mac_address[6] = {82,84,00,18,52,86} ; // Mac address, 6 bytes
struct tx_desc *tx_ring;
char *tx_buffers[NUM_TX_DESC];
struct rx_desc *rx_ring;
char *rx_buffers[NUM_RX_DESC];


static int e1000_page_alloc(char **va_store, int perm);
static physaddr_t va2pa(void *va);



// Initializes transmision
void
init_transmission(void)
{
	cprintf("E1000 initializing transmission\n");

	// Allocate memory for descriptor ring
	char *va;
	int r;
	if((r = e1000_page_alloc(&va, PTE_P | PTE_W)) < 0)
		panic("e1000_page_alloc: %e", r);
	tx_ring = (struct tx_desc *) va;

	// Allocate memory for the buffers
	int i;
	for (i = 0; i < NUM_TX_DESC; i++) {
		if((r = e1000_page_alloc(&va, PTE_P | PTE_W)) < 0)
			panic("e1000_page_alloc: %e", r);
		tx_buffers[i] = va;
	}

	

	// Initial settings of the tx_descriptors
	for (i = 0; i < NUM_TX_DESC; i++) {
		// Set CMD.RS, 
		tx_ring[i].cmd |= E1000_TXD_CMD_RS;
		// Set STATUS.DD, 
		tx_ring[i].status |= E1000_TXD_STAT_DD;
	}


	// TDBAH & TDBAL (Transmit Descriptor Ring address)
	
	E1000_REG(E1000_TDBAL) = va2pa(tx_ring);

	// TDLEN (Transmit Descriptor Ring length in bytes)
	
	E1000_REG(E1000_TDLEN) = NUM_TX_DESC * sizeof(struct tx_desc);

	// TDH & TDT (Transmit Decriptor Ring Head and Tail)
	E1000_REG(E1000_TDH) = 0;
	E1000_REG(E1000_TDT) = 0;

	// TCTL (Transmit Control Register)
	// Enable TCTL.EN
	E1000_REG(E1000_TCTL) |= E1000_TCTL_EN;
	// Enable TCTL.PSP
	E1000_REG(E1000_TCTL) |= E1000_TCTL_PSP;
	
	
	// Configure TCTL.COLD to (40h)
	E1000_REG(E1000_TCTL) &= (~E1000_TCTL_COLD | 0x00040000); // Hard coded...

	// TIPG
	E1000_REG(E1000_TIPG) = 0;
	E1000_REG(E1000_TIPG) += (10 <<  0); // TIPG.IPGT = 10, bits 0-9
	E1000_REG(E1000_TIPG) += ( 4 << 10); // TIPG.IPGR1 = 4 (2/3*IPGR2), 10-19
	E1000_REG(E1000_TIPG) += ( 6 << 20); // TIPG.IPGR2 = 6, bits 20-29
}

// Transmit packet
void
transmit_packet(void *buf, size_t size)
{
	// Initial checkings
	if (size > MAX_PACKET_SIZE)
		panic("Packet size is bigger than the maximum allowed");
	if (!buf)
		panic("Null pointer passed");

// if ring is not full
		uint32_t tail = E1000_REG(E1000_TDT);
	if (!(tx_ring[tail].status & 0x01)) {
		// Drop packet 
		cprintf("tx_ring[tail] DD is not set: tx_ring is full. "
			"Transmission aborted.\n");
		return;
	}

	// Set CMD.EOP, 
	tx_ring[tail].cmd |= E1000_TXD_CMD_EOP;
	// Set STAT.DD to 0, 
	tx_ring[tail].status &= ~E1000_TXD_STAT_DD;

	// Put packet data in buffer
	memset(tx_buffers[tail], 0, PGSIZE);
	memmove(tx_buffers[tail], buf, size);

	// Update tx descriptor
	tx_ring[tail].addr = (uint64_t) va2pa(tx_buffers[tail]); 
	tx_ring[tail].length = (uint16_t) size;

	

	// Update tail
	tail = (tail + 1) % NUM_TX_DESC;
	E1000_REG(E1000_TDT) = tail;
}

// Initializes receive
void
init_receive(void)
{
	cprintf("E1000 initializing receive\n");

	
	// Allocate memory for descriptor ring
	char *va;
	int r;
	if((r = e1000_page_alloc(&va, PTE_P | PTE_W)) < 0)
		panic("e1000_page_alloc: %e", r);
	rx_ring = (struct rx_desc *) va;

	// Allocate memory for the buffers
	int i;
	for (i = 0; i < NUM_RX_DESC; i++) {
		if((r = e1000_page_alloc(&va, PTE_P | PTE_W)) < 0)
			panic("e1000_page_alloc: %e", r);
		rx_buffers[i] = va;
	}

	

	// Initial settings of the rx_descriptors
	for (i = 0; i < NUM_RX_DESC; i++) {
		

		// Buffer address
		rx_ring[i].addr = (uint64_t) va2pa(rx_buffers[i]);
	}

	// The last descriptor starts pointed by the tail
	// The rx descriptor pointed by the tail is always software owned and
	// holds no packet (DD=1, EOP=1)
	rx_ring[NUM_RX_DESC-1].status |= E1000_RXD_STAT_DD;
	rx_ring[NUM_RX_DESC-1].status |= E1000_RXD_STAT_EOP;

	
	uint32_t mac_addr_low_32 =
		(((uint32_t) mac_address[0]) <<  0) +
		(((uint32_t) mac_address[1]) <<  8) +
		(((uint32_t) mac_address[2]) << 16) +
		(((uint32_t) mac_address[3]) << 24);
	uint32_t mac_addr_high_16 =
		(((uint32_t) mac_address[4]) << 0) +
		(((uint32_t) mac_address[5]) << 8);
	E1000_REG(E1000_RAL0) = mac_addr_low_32;
	E1000_REG(E1000_RAH0) = mac_addr_high_16;
	E1000_REG(E1000_RAH0) |= E1000_RAH0_AV; // Set E1000_RAH0 

	

	// RDBAL and RDBAH (Receive Descriptor Ring address)
	// Always store physical address, not the virtual address!
	// Don't use RDBAH as we are using 32 bit addresses
	E1000_REG(E1000_RDBAL) = va2pa(rx_ring);

	// RDLEN (Receive Descriptor Ring length in bytes)
	
	E1000_REG(E1000_RDLEN) = NUM_RX_DESC * sizeof(struct rx_desc);

	// RDH and RDT (rx_ring head and tail indexes)
	E1000_REG(E1000_RDH) = 0;
	E1000_REG(E1000_RDT) = NUM_RX_DESC - 1;

	// RCTL (Receive Control Register) (Initial values are all 0)
	
	E1000_REG(E1000_RCTL) |= E1000_RCTL_EN;
	
	// RCTL.BAM = 1b
	E1000_REG(E1000_RCTL) |= E1000_RCTL_BAM;
	
	// RCTL.SECRC = 1b (Strips the CRC from packet)
	E1000_REG(E1000_RCTL) |= E1000_RCTL_SECRC;
}

// Receive packet function. If there is no packet to be received, does nothing.
// The invariants are:
//   Descriptors owned by software: DD and EOP is set
//   Descriptors owned by hardware: DD and EOP are not set
//   The desc. pointed by the tail is SW-owned, but holds no packet.
void
receive_packet(void *buf, size_t *size_store)
{
	// Initial checkings
	if (!buf || !size_store)
		panic("Null pointer passed");

	uint32_t tail = E1000_REG(E1000_RDT);
	uint32_t next = (tail+1)%NUM_RX_DESC;

	// Analyzes if the next is sw owned(DD = 1) or hw owned (DD = 0)
	if (rx_ring[next].status & E1000_RXD_STAT_DD) {
		
		memmove(buf, rx_buffers[next], (size_t)rx_ring[next].length);
		*size_store = (size_t) rx_ring[next].length;

		// Current tail becomes hw-owned (DD=0, EOP=0)
		rx_ring[tail].status &= ~E1000_RXD_STAT_DD;
		rx_ring[tail].status &= ~E1000_RXD_STAT_EOP;

		// Now make tail point to next
		E1000_REG(E1000_RDT) = next;
	} else {
		
		return;
	}
}


// Initialize the E1000, 
int
attach_e1000(struct pci_func *pcif)
{
	
	pci_func_enable(pcif);

	physaddr_t pa = pcif->reg_base[0];
	size_t size = pcif->reg_size[0];
	e1000 = mmio_map_region(pa, size);

	


	// Initializations
	init_transmission();
	

	

	return 0;
}



//page allocation
// Returns:
//   0 on success
//   -E_NO_MEM if there is no more page to allocate a page or page table for mapping
static int
e1000_page_alloc(char **va_store, int perm)
{
	// Hold the virtual address of the next free page in virtual address space
	static char *nextfree;

	
	// The chosen address for that was MMIOLIM, 
	if (!nextfree) {
		nextfree = (char *) MMIOLIM;
	}

	
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if (!pp) {
	        return -E_NO_MEM;
	}

	
	int r;
	if ((r = page_insert(kern_pgdir, pp, nextfree, perm)) < 0) {
	        page_free(pp);
	        return -E_NO_MEM;
	}

	
	if(va_store)
		*va_store = nextfree;

	// Increment to next free page, and returns success
	nextfree += PGSIZE;
	return 0;
}

// Translates virtual address to physical address

static physaddr_t
va2pa(void *va)
{
	struct PageInfo *pp = page_lookup(kern_pgdir, va, NULL);
	if (!pp)
		panic("va2pa: va is not mapped");
	return page2pa(pp);
}

