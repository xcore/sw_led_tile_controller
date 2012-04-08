/*
 * applicationPackageDispatcher.xc
 *
 *  Created on: 22.12.2011
 *      Author: marcus
 */

#include <string.h>

#include "ethApplicationHandler.h"
#include "ethPkt.h"
#include "applicationPackets.h"

const char magicNumber[4] = {'X', 'M', 'O', 'S' };

int isValidPacket(s_packetMac* incoming_packet,
		const unsigned char own_mac_address[],
		const unsigned char own_ip_address[]) {
	//check if it as a proper pacakge for the local server
	//first of all convert it to a more understandable packet structure
	s_packetMac *mac_packet = (s_packetMac *) incoming_packet; //TODO or is it the payload of the packet?
	s_packetIp *ip_packet = (s_packetIp *) mac_packet->payload;

	//currently we are only dealing with data update UUDP packages marked by 'XMOS' in the header
	if (getShort(mac_packet->ethertype) == ETHERTYPE_IP
			&& getChar(ip_packet->proto) == PROTO_UDP) {
		  if (memcmp(ip_packet->dest, own_ip_address, 4)==0 || ip_packet->dest[3] != 0xFF) {
			  s_packetUdp *udp_packet = (s_packetUdp *)ip_packet->payload;
		      if(getShort(udp_packet->destport) == PORT_XMOS)
		      {
		        s_packetXmos *xmos_packet = (s_packetXmos *)udp_packet->payload;

		        // Verify magic word
		        if (memcmp( (void*)xmos_packet->magicNumber , (void*)magicNumber, 4) == 0)
		        {
		        	//it is packet for our destination port, boradcastet or for our address and with
		        	//XMOS in the header - complete win - we handle it
		        	return -1;
		        }
		      }

		  }
	}
	return 0;
}

int handlePacket(s_packetMac* mac_packet, s_packetMac* outgoing_packet,
		const unsigned char own_mac_address[],
		const unsigned char own_ip_address[]) {
	return 0;
}
