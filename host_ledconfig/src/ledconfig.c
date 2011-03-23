// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedConfig
 * Version: 9.10.0
 * Build:   N/A
 * File:    src/ledconfig.c
 *
 **/                                   

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#ifdef HAVE_SYS_MMAN_H
#include <sys/mman.h>
#endif
#include <math.h>


#ifdef _WIN32

#include <windows.h>  /* for Sleep() in dos/mingw */
#define nsleep(nanoseconds) Sleep((nanoseconds)/1000000000) /* from mingw.org list */
#include <winsock2.h>

#else

int nsleep(unsigned long nanosec)  
{  
    struct timespec req={0},rem={0};  
    time_t sec=(int)(nanosec/1000000000);  
    nanosec=nanosec-(sec*1000000000);  
    req.tv_sec=sec;  
    req.tv_nsec=nanosec;  
    nanosleep(&req,&rem);  
    return 1;  
}  

#include <netdb.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>

#endif

#include "ethPkt.h"
#include "ethOther.h"

#define XMOS_VERSION             0x01
#define XMOS_DATA                0x02
#define XMOS_LATCH               0x03
#define XMOS_GAMMAADJ            0x04
#define XMOS_INTENSITYADJ        0x05
#define XMOS_SINTENSITYADJ       0x06
#define XMOS_RESET               0x07
#define XMOS_AC_1                0x08
#define XMOS_AC_2                0x09
#define XMOS_AC_3                0x0A
#define XMOS_AC_4                0x0B
#define XMOS_SINTENSITYADJ_PIX   0x0C
#define XMOS_CHANGEDRIVER        0x0D

#define NUM_HOSTS    256
#define BCAST_HOST   "255.255"
#define seek(p, v, r) {char *tmp; tmp = strtok(p, " "); if (tmp == NULL) return 1; else v = r; }

#ifndef _WIN32
#define WSAGetLastError() 0
#endif

// Structs and globals .............................
typedef struct {
  char prefix[100];
	int port;
	int fd; /* file descriptor */
	struct sockaddr_in addrs[NUM_HOSTS][NUM_HOSTS];
} xudp_t;
static xudp_t xudp;




static s_packetXmos xudp_packet;
static int          xudp_packetlen_b;
const char magicNumber[4] = {'X', 'M', 'O', 'S' };


// UDP Functions .....................................

static int udp_init()
{
	struct hostent *dest;
  char suffix[3];
  int x,y;

#ifdef _WIN32
  {
	  WSADATA wsaData;
    int iResult;

    // Initialize Winsock
    iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (iResult != 0) {
        printf("WSAStartup failed: %d\n", iResult);
        return 1;
    }
  }
#endif

  // Create socket
  xudp.fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (xudp.fd < 0) {
	  printf("Couldn't create socket %i.\n", WSAGetLastError());
	  
		return 1;
	}
	
	// Set broadcast messages possible
	{
    int bOptVal = 1;
    int bOptLen = sizeof(bOptVal);
	  setsockopt (xudp.fd, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, bOptLen);
	}
	
  /* Init all addresses */
	for (x = 0; x < 256; x++)
	{
    for (y = 0; y < 256; y++)
    {
      struct hostent *dest;
      char address[100];
      
      sprintf(address, "%s.%i.%i", xudp.prefix, y, x);
      dest = gethostbyname(address);
      if (!dest) {
        printf("Gethostbyname failed for %s\n", address);
        printf("UDP init failed\n");
	      return 1;
      }

      xudp.addrs[x][y].sin_family = AF_INET;
      xudp.addrs[x][y].sin_port = htons(xudp.port);

      memcpy(&xudp.addrs[x][y].sin_addr.s_addr, dest->h_addr_list[0], dest->h_length);
    }
  }

	return 0;
}

static int udp_send(char *p) {
  unsigned int x,y;
  char d[8];
  char *q;
  
  memcpy(d,p,8);
  d[7] = 0;
  p = &d[0];
  q = p;
  
  while (*q != '\0' && *q != '.') q++;
  if (*q == '\0') return 1;
  *q = '\0';
  x = atoi(p);
  q++;
  y = atoi(q);  

  if ( x < 256 && y < 256)
  {
	  if (sendto(xudp.fd, (void *)&xudp_packet, xudp_packetlen_b, 0, (struct sockaddr *)&xudp.addrs[x][y], sizeof(struct sockaddr_in)) != xudp_packetlen_b)
	  { 
		  printf("xudp: Unable to send to node %i,%i.\n", x,y);
		  return 1;
	  }
	  else
	  {
	    return 0;
	  }
	}
	else
	{
	  printf("xudp: Node %i,%i out of bounds.\n", x,y);
	  return 1;
  }
}

static void udp_close() {
  close(xudp.fd);
}


void printCommand(char *a, char *b)
{
  int i;
  printf("%s\n   %s\n\n",a,b);
}

void listCommands(void)
{
  printf("List of commands:\n\n");
  printCommand("[autoconfigure/ac]", "Automatically set the IP addresses of client nodes chains.");
  printCommand("[intensity/i] ipAddress intensity", "Set the current gain of the Macroblock drivers from 0-255 (nonlinear).");
  printCommand("[softintensity/si] [R/G/B/A] ipAddress intensity", "Set the intensity multiplier from 0-255 for channel R(Red), G(Green), B(Blue) or A(All).");
  printCommand("[softintensitypixel/sip] [R/G/B/A] ipAddress x y intensity", "Set the intensity multiplier from 0-255 for channel R(Red), G(Green), B(Blue) or A(All) on a specific pixel (x,y).");
  printCommand("[gamma/g] [R/G/B/A] ipAddress gamma", "Set the gamma exponent for channel R(Red), G(Green), B(Blue) or A(All).");
  printCommand("[reset/r] ipAddress", "Reset the XCore.");
  printCommand("[changedriver/cd] ipAddress driverType", "Instruct the node to use a new driver type.");
  printf("\n");
}

void trim(char *str)
{
  int i;
  if (strlen(str))
  {
    char *ptr = str + strlen(str) - 1;
    for (i = 0; i < strlen(str); i++)
    {
      if (*ptr == ' ' || *ptr == '\n')
        *ptr = '\0';
      else
        break;
      ptr--;
    }
  }
} 

unsigned short bitrev(unsigned short input)
{
  unsigned short result = 0;
  int i;
  for (i=0; i<16; i++)
  {
    result <<= 1;
    if (input & 1)
      result |= 1;
    input >>= 1;
  }
  return result;
}

int newSIntensity()
{
  char colchan;
  char *ip;
  int intensity;
  unsigned int tmp;
  s_packetIntensity *inte = (s_packetIntensity *)xudp_packet.payload;

  seek(NULL, colchan, *tmp); 
  seek(NULL, ip, tmp);
  seek(NULL, inte->intensity, atoi(tmp));
  
  inte->colchan[0] = colchan;
  xudp_packet.identifier = getShort(XMOS_SINTENSITYADJ);
  xudp_packetlen_b = sizeof(s_packetIntensity) + 20;
  if (udp_send(ip))
    printf("Soft-Intensity Set packet failed to send\n");
  else
    printf("Soft-Intensity Set packet sent\n");
  return 0;
}    

int newSIntensityPix()
{
  char colchan;
  char *ip;
  int intensity,x,y;
  unsigned int tmp;
  s_packetIntensityPix *inte = (s_packetIntensityPix *)xudp_packet.payload;

  seek(NULL, colchan, *tmp); 
  seek(NULL, ip, tmp);
  seek(NULL, inte->x, atoi(tmp));
  seek(NULL, inte->y, atoi(tmp));
  seek(NULL, inte->intensity, atoi(tmp));
  
  inte->colchan = colchan;
  xudp_packet.identifier = getShort(XMOS_SINTENSITYADJ_PIX);
  xudp_packetlen_b = sizeof(s_packetIntensityPix) + 20;
  if (udp_send(ip))
    printf("Soft-Intensity-Pixel Set packet failed to send\n");
  else
    printf("Soft-Intensity-Pixel Set packet sent\n");
  return 0;
}    

int sendReset()
{
  char *ip;
  unsigned int tmp;
  
  seek(NULL, ip, tmp);
  xudp_packet.identifier = getShort(XMOS_RESET);
  xudp_packetlen_b = 20;
  if (udp_send(ip))
    printf("Reset packet failed to send\n");
  else
    printf("Reset packet sent\n");
  
  return 0;
}

int changeDriver()
{
  char *ip;
  int dtype;
  char *tmp;
  s_packetDriverType *dt = (s_packetDriverType *)xudp_packet.payload;

  seek(NULL, ip, tmp);
  seek(NULL, dt->drivertype, atoi(tmp));

  xudp_packet.identifier = getShort(XMOS_CHANGEDRIVER);
  xudp_packetlen_b = sizeof(s_packetDriverType) + 20;
  if (udp_send(ip))
    printf("Driverchange packet failed to send\n");
  else
    printf("Driverchange packet sent\n");

  return 0;
}



int newIntensity()
{
  char *ip;
  int intensity;
  int i=0;
  char *tmp;
  s_packetIntensity *inte = (s_packetIntensity *)xudp_packet.payload;

  seek(NULL, ip, tmp);
  seek(NULL, inte->intensity, atoi(tmp));

  inte->colchan[0] = 'A';
  xudp_packet.identifier = getShort(XMOS_INTENSITYADJ);
  xudp_packetlen_b = sizeof(s_packetIntensity) + 20;
  if (udp_send(ip))
    printf("Intensity Set packet failed to send\n");
  else
    printf("Intensity Set packet sent\n");

  return 0;
}

int newGamma()
{
  char colchan;
  char *ip;
  float gamma;

  seek(NULL, colchan, *tmp); 
  seek(NULL, ip, tmp);
  seek(NULL, gamma, atof(tmp));

  if (gamma > 0.0f && gamma < 100.0f)
  {
    // Generate new gamma curve
    // Num entries = 256, max value = 0xFFFF, bitreverse = 1
#define NUMENTRIES 256
#define MAXVALUE   0xFFFF
#define BITREVERSE
    int i=0;
    s_packetGammaTable *gt;
    
    gt = (s_packetGammaTable *)xudp_packet.payload;
    // Gamma table generate
    for (i=0; i<NUMENTRIES; i++)
    {
      gt->gammaTable[i] = (unsigned short)(pow((float)i / (float)(NUMENTRIES - 1), gamma) * (MAXVALUE - 1));
#ifdef BITREVERSE
      gt->gammaTable[i] = bitrev(gt->gammaTable[i]);
#endif
    }
    // Send gamma table
    gt->colchan[0] = colchan;
    xudp_packet.identifier = getShort(XMOS_GAMMAADJ);
    xudp_packetlen_b = sizeof(s_packetGammaTable) + 20;
    if (udp_send(ip))
      printf("Gamma Set packet failed to send\n");
    else
      printf("Gamma Set packet sent\n");
  }
  return 0;
}


int sendAutoConfigure(void)
{
  xudp_packet.identifier = getShort(XMOS_AC_1);
  xudp_packetlen_b = 6;
  if (udp_send(BCAST_HOST))
  {
    printf("Autoconfigure packet 1 failed to sent\n");
    return 1;
  }

  nsleep(1000000000);
  xudp_packet.identifier = getShort(XMOS_AC_3);
  if (udp_send(BCAST_HOST))
  {
    printf("Autoconfigure packet 2 failed to sent\n");
    return 1;
  }
  printf("Autoconfigure packets sent\n");
  return 0;
}


int processCMDArgs(int argc, char * argv[])
{
  char arg[20];
  char value[20];
  int i,j;
  int prefixset=0, portset=0;

  // Defaults:
  strcpy(xudp.prefix, "192.168");
  xudp.port = 306;
  
  for (i = 1; i < argc; i++)
  {
    trim(argv[i]);
    if (strncmp(argv[i], "--prefix=", 9) == 0)
    {
      if (prefixset)
      {
        printf("ERROR: prefix set multiple times\n");
        return (1);
      }
      else
      {
        char *ptr;  
        argv[i] += 9;
        strcpy(xudp.prefix, argv[i]);
        printf("Prefix set to %s\n", argv[i]);
        prefixset = 1;
      }
    }
    else if (strncmp(argv[i], "--port=", 7) == 0)
    {
      if (portset)
      {
        printf("ERROR: Port set multiple times\n");
        return(1);
      }
      else
      {
        argv[i] += 7;
        xudp.port = atoi(argv[i]);
        printf("Port set to %d\n", atoi(argv[i]));
        portset = 1;
      }
    }
    else
    {
      printf("ERROR: Unrecognised argument %s\n", argv[i]);
      return 1;
    }
  }
  
  if (!prefixset)
  { 
    printf("Using default prefix: %s\n", xudp.prefix);
  }
  
  if (!portset)
  { 
    printf("Using default port: %d\n", xudp.port);
  }
  return 0;
}



// User Interface ........................................
int main(int argc, char * argv[])
{
  int end = 0;
  char cmd[100];
  char arg0[20], arg1[20], arg2[20], arg3[20];
  
  memcpy(xudp_packet.magicNumber, magicNumber, 4);
  xudp_packet.identifier = getShort(XMOS_DATA);

  printf("--- XMOS Led Tile Configuration App ---\n");

  if (processCMDArgs(argc, argv))
  {
    fflush(stdout);
    return 1;
  }
  
  udp_init();
  
  printf("\nType 'help' for command list\n");
  do
  {
    char *args;
    printf("->");
    fflush(stdout);
    fgets(cmd, sizeof(cmd), stdin);
    trim(cmd);
    args = strtok(cmd, " \0");
    if (strcmp(args, "quit") == 0 || strcmp(args, "q") == 0)
    {
      end = 1;
    }
    else if (strcmp(args, "changedriver") == 0 || strcmp(args, "cd") == 0)
    {
      if (changeDriver())
        printf("Incorrect format: [changedriver/cd] [ipAddress] [driverType]\n");
    }
    else if (strcmp(args, "help") == 0)
    {
      listCommands();
    }
    else if (strcmp(args, "gamma") == 0 || strcmp(args, "g") == 0)
    {
      if (newGamma())
        printf("Incorrect format: [gamma/g] [R/G/B/A] [ip] [gamma]\n");
    }
    else if (strcmp(args, "intensity") == 0 || strcmp(args, "i") == 0)
    {
      if (newIntensity())
        printf("Incorrect format: [intensity/i] [ip] [intensity (0-255)]\n");
    }
    else if (strcmp(args, "softintensitypix") == 0 || strcmp(args, "sip") == 0)
    {
      if (newSIntensityPix())
        printf("Incorrect format: [softintensitypixel/sip] [R/G/B/A] [ip] [x] [y] [intensity (0-255)]\n");
    }
    else if (strcmp(args, "softintensity") == 0 || strcmp(args, "si") == 0)
    {
      if (newSIntensity())
        printf("Incorrect format: [softintensity/si] [R/G/B/A] [ip] [intensity (0-255)]\n");
    }
    else if (strcmp(args, "reset") == 0 || strcmp(args, "r") == 0)
    {
      if (sendReset())
        printf("Incorrect format: [reset/r] [ip]\n");
    }
    else if (strcmp(args, "ac") == 0 || strcmp(args, "autoconfigure") == 0)
    {
      if (sendAutoConfigure())
        printf("Incorrect format: [autoconfigure/ac]");
    }
    else
    {
      printf("Unrecognised Command %s\n", cmd);
    }
  } while (end == 0);

  udp_close();
}

