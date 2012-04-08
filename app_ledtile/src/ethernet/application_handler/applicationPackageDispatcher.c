/*
 * applicationPackageDispatcher.xc
 *
 *  Created on: 22.12.2011
 *      Author: marcus
 */

#include "ethApplicationServer.h"

int isValidPacket(s_packetMac* incoming_packet, const unsigned char own_mac_address[], const unsigned char own_ip_address[]) {
	//currently we are only dealing with UDP packages (TFTP or data update UUDP packages marked by 'XMOS' in the header
/*
	 if (getShort(incoming_packet.ethertype) == ETHERTYPE_IP && getChar(i->proto) == PROTO_UDP) {
		 return -1;
	 } else {
		 return 0;
	 }
*/
}

int handlePacket(s_packetMac* mac_packet, s_packetMac* outgoing_packet, const unsigned char own_mac_address[], const unsigned char own_ip_address[]) {
	return 0;
}
