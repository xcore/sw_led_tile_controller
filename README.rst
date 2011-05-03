LED Tile Controller
...................

:Stable release: unknown

:Status:  alpha

:Maintainer:  interative-matter

:Description:  LED controller code 


Key Features
============

The XMOS LED Reference Design is an Ethernet-based system featuring daisychains of 
100BASE-T scan boards off a central 100/1000BASE-T Ethernet switch. 
The design uses standard Ethernet technologies, where possible, to enable ease of upgradability, 
component availability and compliance with third-party technologies. 
The XMOS solution is based on the XS1-G4 software defined silicon programmable device.

* Driving serial (currently) LED drivers with gamma correction, singel LED level adjustment
* Internal double buffered pixel buffer
* Updateable via ethernet
* Configurable via ethernet
* Two 10/100Mbps full duplex MII layers
* Dynamic Receive buffers (FIFO) 
* 3-port Layer 2 Ethernet Switch (2 external, 1 internal)
* Internal UDP/IP Ethernet server

Mplayer plugin
==============

For demonstration purposes, XMOS has written a plugin for the open-source media player 'MPlayer' (http://www.mplayerhq.hu). 
MPlayer supports most MPEG/VOB, AVI and many other media files. MPlayer can be compiled for Windows, Mac OSX and 
various Linux distributions. Binaries for Windows 32bit and Mac OSX are included in the release.
The purpose of the plugin is to segment the video stream into tiles, packetise the data, and output it over UDP.

The mplayer plugin is open source and currently not hosted on github. You can download it from the original software 
from http://www.xmos.com/applications/led-signs-and-displays

To Do
=====

* Documentation, documentation, documentation
* Documentation in the code.
* LED Driver Hardware schematics (at least not found yet)
* Reusing more existing xcore repositories (e.g. for ethernet)
* Restructuring the source a bit

Firmware Overview
=================

The root directory structure is:

* bootloader - Source and Binary files for XC-3 Bootloader 
* doc        - Application Note directory
* ledconfig  - Source and Binary files for Host-side LED Configuration application
* ledtile    - Source and Binary files for XC-3 LED Tile Application
* mplayer    - Source and Binary files for Host-side MPlayer UDP modified application


Known Issues
============

* <Bullet pointed list of problems>

Required Repositories
================

* xcommon git\@github.com:xcore/xcommon.git

Support
=======

Please post all questions, issues and erros you got here on github on https://github.com/xcore/ap_led_tile_controller/issues

If you post to the xcore community at https://www.xcore.com/ it is also very likely that you get help and support but laks 
the tracking of the issue system.
