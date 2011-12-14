/*
 * packet_helpers.h
 *
 *  Created on: 14.12.2011
 *      Author: marcus
 */

#ifndef PACKET_HELPERS_H_
#define PACKET_HELPERS_H_


//some standard definitions for some package types
extern unsigned char ethertype_ip[];
extern unsigned char ethertype_arp[];

/*
 * Decides if a package is of a certain ethernet type.
 * The type is a two byte array,
 * the data is the pakage
 * Position 12 & 13 are checked against the type.
 * returns 0 if not, 1 if it is that type.
 */
int is_ethertype(unsigned char data[], unsigned char type[]);

/*
 * Checks if a package is meant for the given mac address.
 * Validates the first 6 bytes of the package against the mac address (6 bytes too)
 */
int is_mac_addr(unsigned char data[], unsigned char addr[]);

/*
 * Checks if the given package is a broadcast package.
 * For beeing a broadcast package the first 6 bytes must be 0xFF
 */
int is_broadcast(unsigned char data[]);

#endif /* PACKET_HELPERS_H_ */
