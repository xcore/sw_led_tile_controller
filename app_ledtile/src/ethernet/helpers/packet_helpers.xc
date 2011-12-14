/*
 * packet_helpers.xc
 *
 *  Created on: 14.12.2011
 *      Author: marcus
 */

//some standard definitions for some package types
unsigned char ethertype_ip[] = {0x08, 0x00};
unsigned char ethertype_arp[] = {0x08, 0x06};

#pragma unsafe arrays
int is_ethertype(unsigned char data[], unsigned char type[]){
	int i = 12;
	return data[i] == type[0] && data[i + 1] == type[1];
}

#pragma unsafe arrays
int is_mac_addr(unsigned char data[], unsigned char addr[]){
	for (int i=0;i<6;i++){
#pragma xta label "sc_ethernet_is_mac_addr_1"
#pragma xta command "add loop sc_ethernet_is_mac_addr_1 6"
          if (data[i] != addr[i]){
			return 0;
		}
	}

	return 1;
}

#pragma unsafe arrays
int is_broadcast(unsigned char data[]){
	for (int i=0;i<6;i++){
#pragma xta label "sc_ethernet_is_broadcast_1"
#pragma xta command "add loop sc_ethernet_is_broadcast_1 6"
          if (data[i] != 0xFF){
			return 0;
		}
	}

	return 1;
}
