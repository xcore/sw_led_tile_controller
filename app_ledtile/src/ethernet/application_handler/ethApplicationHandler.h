/*
 * ethApplicationServer.h
 *
 * Defines how the local server has to look in order to handle packages
 *
 *  Created on: 22.12.2011
 *      Author: marcus
 */

#ifndef ETHAPPLICATIONSERVER_H_
#define ETHAPPLICATIONSERVER_H_
#include "ethPkt.h"

// XMOS Packets come in on this port
#define PORT_XMOS          306

#ifndef __XC__
/**
 * TODO: correct documentation format
 * check routine to see if the packae is valid - need as it is used for package filtering and package handling.
 * This routine must be really fast since it is used to filter any packet on the network.
 * Parameter incoming_packet: The MAC packet that is coming from the ethernet adapter
 * Parameter own_mac_address: The local mac adress if it is neccessary for filtering
 * Parameter own_ip_address: The local ip address if it is important for filtering
 * Return: 0 if the package is not to be handled by the application code, anything else (e.g. -1) if it should be dispatched to the applicaiton code
 */
int isValidAppPacket(s_packetMac* mac_packet, const unsigned char own_mac_address[], const unsigned char own_ip_address[]);
#else
//those are the XC variants of the  above functions - they look a bit different to automatically handle th casting of the byte arrays to structs
int isValidAppPacket(s_packetMac& mac_packet, const unsigned char own_mac_address[], const unsigned char own_ip_address[]);
#endif

#ifndef __XC__
/**
 * application specific package handler.
 * Only packages which are prefiltered by isValidPackage are dispatched to the local handling function - so a proper check can be omitted.
 * Parameter incoming_package:the incoming MAC packet
 * Parameter outgoing_pacakge: storage area for a package to be send to out. The return value of the function deteremines if a package is sent or not
 * TODO: & what if we want to send more than one package?? A separate sender function may be easier
 * Parameter own_mac_address: The local mac adress if it is neccessary for sending answers
 * Parameter own_ip_address: The local ip address if it is important for sending answers
 *
 */
int handleAppPacket(s_packetMac* mac_packet, s_packetMac* outgoing_packet, const unsigned char own_mac_address[], const unsigned char own_ip_address[],
		chanend cTx,
		chanend cLedBuffer, chanend cLedCmd,
		chanend cFlash);
#else
extern int handleAppPacket(s_packetMac& mac_packet, s_packetMac& outgoing,const unsigned char own_mac_address[], const unsigned char own_ip_address[],
		chanend cTx,
		chanend cLedBuffer, chanend ,
		chanend cFlash);

#endif

#endif /* ETHAPPLICATIONSERVER_H_ */
