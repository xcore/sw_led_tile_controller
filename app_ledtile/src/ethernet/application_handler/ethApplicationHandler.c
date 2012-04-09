/*
 * applicationPackageDispatcher.xc
 *
 *  Created on: 22.12.2011
 *      Author: marcus
 */

#include <string.h>
#include <xs1.h>
#include <xccompat.h>

#include "ethApplicationHandler.h"
#include "ethPkt.h"
#include "applicationPackets.h"
#include "ledprocess.h"
#include "ledbufferwriter.h"
#include "pktbufferclient.h"
#include "flashclient.h"
#include "misc.h"
#include "xmosAC.h"
#include "localConfig.h"
#include "ethIp.h"
#include "ethernet_tx_client.h"

const char magicNumber[4] = { 'X', 'M', 'O', 'S' };

//this is the struct save our local networking configuration
s_xmosAC xmosACdata;

//local function definitions
/* TODO disabled until we get a better understanding
void sendACforwardPackets(s_packet *packet, s_addresses *addresses,
		unsigned cTx);
*/

int isValidPacket(s_packetMac* mac_packet,
		const unsigned char own_mac_address[],
		const unsigned char own_ip_address[]) {

	//check if it as a proper pacakge for the local server
	//first of all convert it to a more understandable packet structure
	s_packetIp *ip_packet = (s_packetIp *) mac_packet->payload;

	//currently we are only dealing with data update UUDP packages marked by 'XMOS' in the header
	if (getShort(mac_packet->ethertype) == ETHERTYPE_IP
			&& getChar(ip_packet->proto) == PROTO_UDP) {
		if (memcmp(ip_packet->dest, own_ip_address, 4) == 0
				|| ip_packet->dest[3] != 0xFF) {
			s_packetUdp *udp_packet = (s_packetUdp *) ip_packet->payload;
			if (getShort(udp_packet->destport) == PORT_XMOS) {
				s_packetXmos *xmos_packet =
						(s_packetXmos *) udp_packet->payload;

				// Verify magic word
				if (memcmp((void*) xmos_packet->magicNumber,
						(void*) magicNumber, 4) == 0) {
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
		const unsigned char own_ip_address[], chanend cTx, chanend cLedBuffer,
		chanend cLedCmd, chanend cFlash) {
	//we do not check if the package is meant for us - the isValidPackage routine must ahve been called and return TRUE (!=0)
	//let's start the unpackaging of the packet
	//get the ip packet
	s_packetIp *ip_packet = (s_packetIp *) mac_packet->payload;
	//get the udp packet
	s_packetUdp *udp_packet = (s_packetUdp *) ip_packet->payload;
	//unwrap the XMOS packet
	s_packetXmos *xmos_packet = (s_packetXmos *) udp_packet->payload;

	// Check the XMOS identifier
	switch (getShort(xmos_packet->identifier)) {
	case (XMOS_VERSION): {
		//TODO return some proper version information
		return 1;
	}
		break;
	case (XMOS_DATA): {
		// This is a LED data packet
		unsigned char *ptr;

		// if not our IP, exit
		if (memcmp(ip_packet->dest, own_ip_address, 4))
			return 0;

		s_packetData *data_packet = (s_packetData *) xmos_packet->payload;
		ptr = data_packet->data;

		// Check packet
		if (data_packet->datalen + 3 * data_packet->pixptr <= 3 * FRAME_SIZE) {
			// Send to LED frame buffer
			sendLedData(cLedBuffer, (unsigned) data_packet->pixptr,
					data_packet->datalen, ptr);
		}
	}
		break;
	case (XMOS_LATCH): {
		// This is a "New Frame" latch signal
		sendLedLatch(cLedBuffer);
	}
		break;
	case (XMOS_GAMMAADJ): {
		// This is a "adjust gamma table" packet
		int i;

		s_packetGammaTable *gamma_table_packet =
				(s_packetGammaTable *) xmos_packet->payload;

		{
			unsigned data[258] = { XMOS_GAMMAADJ,
					gamma_table_packet->colchan[0] };
			for (i = 0; i < 256; i++) {
				data[i + 2] = (unsigned int) gamma_table_packet->gammaTable[i];
			}
			sendPktData(cLedCmd, 258, data);
		}

		// Write to flash
		if (gamma_table_packet->colchan[0] == 'A') {
			flash_write_gamma(0, gamma_table_packet->gammaTable, cFlash);
			flash_write_gamma(1, gamma_table_packet->gammaTable, cFlash);
			flash_write_gamma(2, gamma_table_packet->gammaTable, cFlash);
		} else if (gamma_table_packet->colchan[0] == 'R') {
			flash_write_gamma(0, gamma_table_packet->gammaTable, cFlash);
		} else if (gamma_table_packet->colchan[0] == 'G') {
			flash_write_gamma(1, gamma_table_packet->gammaTable, cFlash);
		} else if (gamma_table_packet->colchan[0] == 'B') {
			flash_write_gamma(2, gamma_table_packet->gammaTable, cFlash);
		}

	}
		break;
	case (XMOS_INTENSITYADJ):
	case (XMOS_SINTENSITYADJ): {
		// This is an intentsity adjustment packet
		s_packetIntensity *intensity_packet =
				(s_packetIntensity *) xmos_packet->payload;

		{
			unsigned data[3] = { getShort(xmos_packet->identifier),
					intensity_packet->colchan[0], intensity_packet->intensity };
			sendPktData(cLedCmd, 3, data);
		}
	}
		break;
	case (XMOS_SINTENSITYADJ_PIX): {
		// This is an intentsity adjustment packet for a single pixel
		s_packetIntensityPix *intesity_packet =
				(s_packetIntensityPix *) xmos_packet->payload;

		{
			unsigned data[5] = { getShort(xmos_packet->identifier),
					intesity_packet->colchan, intesity_packet->y,
					intesity_packet->x, intesity_packet->intensity };
			sendPktData(cLedCmd, 5, data);
		}
	}
		break;
	case (XMOS_RESET):
		chipReset();
		break;
	case (XMOS_CHANGEDRIVER): {
		s_packetDriverType *driver_type_package =
				(s_packetDriverType *) xmos_packet->payload;

		// Store a command to change the LED Driver
		{
			unsigned data[2] = { getShort(xmos_packet->identifier),
					driver_type_package->drivertype };
			sendPktData(cLedCmd, 2, data);
		}
	}
		break;
/* TODO autoconfiguration is far too complex - so let's start to see if we can get data into this at all - this should go into a different file!!
	case (XMOS_AC_1): {
		s_packetMac outgoing_packet;
		//create pointers to the various parts of the package
		s_packetIp *outgoing_ip_packet = (s_packetIp *) &outgoing_packet.payload;
		//get the udp packet
		s_packetUdp *outgoing_udp_packet = (s_packetUdp *) outgoing_ip_packet->payload;
		//unwrap the XMOS packet
		s_packetXmos *outgoing_xmos_packet = (s_packetXmos *) outgoing_udp_packet->payload;

		//prepare the mac packet
		memcpy((void*) &outgoing_packet.destmac, (void*) mac_packet->destmac, 6);
		memcpy((void*) &outgoing_packet.sourcemac, (void*) own_mac_address, 6);
		outgoing_packet.ethertype = ETHERTYPE_IP;

		//prepare the ip packet
		ipInit(outgoing_ip_packet);
		ip_packet->ttl = 255;

		// Broadcast AC_2 message, include our TTL of AC_1 message
		outgoing_xmos_packet->identifier = getShort(XMOS_AC_2);
		outgoing_xmos_packet->payload[0] = ip_packet->ttl;

		xmosACdata.myCommandTTL = ip_packet->ttl;
		xmosACdata.XstartFlag = 1;
		xmosACdata.XendFlag = 1;
		xmosACdata.YstartFlag = 1;
		xmosACdata.YendFlag = 1;


		setUdpSize(&outgoing_packet, XMOS_SIZE + 1);
		//mac_packet->plen_b = 60;
		udpChecksum(udp_packet);
		ipChecksum(ip_packet);
		//TODO correct size? correct package?? correct interface??
		mac_tx(cTx, (char*) &outgoing_packet, MAC_SIZE+outgoing_ip_pacakge->size, ETH_BROADCAST);
	}
		break;
	case (XMOS_AC_2):
		// If we think we are at the beginning of this chain
		if (xmosACdata.XstartFlag && xmos_packet->payload[0]
				== xmosACdata.myCommandTTL) {
			// Look to see if they are before us in the list
			if (memcmp(mac_packet->sourcemac, own_mac_address, 6) < 0) {
				// We are not at the beginning of the Y chain
				xmosACdata.YstartFlag = 0;
			} else if ((xmosACdata.YendFlag == 0) && (memcmp(
					mac_packet->sourcemac, xmosACdata.nextYNodeMac, 6) < 0)) {
				memcpy(xmosACdata.nextYNodeMac, mac_packet->sourcemac, 6);
			} else {
				xmosACdata.YendFlag = 0;
				memcpy(xmosACdata.nextYNodeMac, mac_packet->sourcemac, 6);
			}
		}

		if (ip_packet->ttl == 255) {
			// Are they on the same chain but before us?
			if (xmos_packet->payload[0] > xmosACdata.myCommandTTL) {
				xmosACdata.XstartFlag = 0;
			}
			// Are they the next node on our chain?
			else if (xmos_packet->payload[0] < xmosACdata.myCommandTTL) {
				memcpy(xmosACdata.nextXNodeMac, mac_packet->sourcemac, 6);
				xmosACdata.XendFlag = 0;
			}
		}
		break;
	case (XMOS_AC_3):
		memcpy((void*) mac_packet->sourcemac, (void*) own_mac_address, 6);
		if (xmosACdata.XstartFlag && xmosACdata.YstartFlag) {
			//create a new IP address and set it
			char new_ip_addresss[4] = { own_ip_address[0], own_ip_address[1],
					START_IP_Y, START_IP_X };
			setIpAddress(new_ip_addresss);
			//but also forward the ip addess to the next node so that it can also assign one
			xmos_packet->payload[6] = START_IP_Y;
			xmos_packet->payload[7] = START_IP_X;
			//sendACforwardPackets(mac_packet, addresses, cTx);
		}
		break;
	case (XMOS_AC_4):
		memcpy((void*) mac_packet->sourcemac, (void*) own_mac_address, 6);
		if (memcmp(xmos_packet->payload, own_mac_address, 6) == 0) {
			//set the ip addresss according to the package data
			char new_ip_addresss[4] = { own_ip_address[0], own_ip_address[1],
					xmos_packet->payload[6], xmos_packet->payload[7] };
			setIpAddress(new_ip_addresss);
			//sendACforwardPackets(packet, addresses, cTx);
		}
		break;
*/ //TODO end of to be converted auto configure stuff
	}
	return -1;
}
/*
void sendACforwardPackets(s_packet *packet, s_addresses *addresses,
		unsigned cTx) {
	s_packetMac *m;
	s_packetIp *i;
	s_packetUdp *u;
	s_packetXmos *x;

	m = (s_packetMac *) packet->pdata;
	i = (s_packetIp *) m->payload;
	u = (s_packetUdp *) i->payload;
	x = (s_packetXmos *) u->payload;

	x->identifier = getShort(XMOS_AC_4);
	setUdpSize(packet, XMOS_SIZE + 8);
	packet->plen_b = 60;

	// If there's another node after us
	if (xmosACdata.XendFlag == 0) {
		i->ttl = 0;
		memcpy(x->payload, xmosACdata.nextXNodeMac, 6);
		x->payload[7]++;
		udpChecksum(u);
		ipChecksum(i);
		//TODO this is deprecated & has to be change
		//ethPhyTx(cTx, packet, &null);
		x->payload[7]--;
	}

	if (xmosACdata.YendFlag == 0) {
		memcpy(x->payload, xmosACdata.nextYNodeMac, 6);
		x->payload[6]++;
		i->ttl = 255;
		udpChecksum(u);
		ipChecksum(i);
		//TODO this is deprecated & has to be change
		//ethPhyTx(cTx, packet, &null);
		x->payload[6]--;
	}
}
*/
