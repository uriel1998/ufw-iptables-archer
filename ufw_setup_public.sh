#!/bin/bash


#http://jhansonxi.blogspot.com/2010/10/ufw-application-profiles.html

##########################################################
# Because otherwise this is a pain
##########################################################

echo "Did you run this script with sudo privileges? If not, Ctrl-C."
echo "Otherwise, press any key to continue."
read

sudo ufw disable

##########################################################
# To reset
##########################################################
echo y | sudo ufw reset

# To delete a rule, add the word delete after ufw, which means you can
# script dynamic rule changing fairly easily.

##########################################################
# Internet Exposed Apps
##########################################################
sudo ufw allow Crashplan
#sudo ufw allow Deluge
#sudo ufw allow Icecast
sudo ufw allow BTSync

##########################################################
# LAN System Apps
##########################################################
# FTP - it's a service, so no app profile
#sudo ufw allow proto tcp from 192.168.1.0/24 to any port 20
#sudo ufw allow proto tcp from 192.168.1.0/24 to any port 21
# WakeOnLan
#sudo ufw allow from 192.168.1.0/24 to any port 9
#sudo ufw allow from 192.168.1.0/24 to any app CUPS
# Getting Mail
#sudo ufw allow from 192.168.1.0/24 to any app Dovecot_IMAP
#sudo ufw allow from 192.168.1.0/24 to any app Dovecot_POP3
#sudo ufw allow from 192.168.1.0/24 to any app Dovecot_IMAPS
#sudo ufw allow from 192.168.1.0/24 to any app Dovecot_POP3S
#sudo ufw allow from 192.168.1.0/24 to any app MySQL
#sudo ufw allow in from 192.168.1.0/24 to any app OpenSSH
#sudo ufw allow from 192.168.1.0/24 to any app Samba
#sudo ufw allow from 192.168.1.0/24 to any app Telnet
#sudo ufw allow from 192.168.1.0/24 to any app WWW
#sudo ufw allow from 192.168.1.0/24 to any app WWW_Secure	

##########################################################
# LAN Media
##########################################################
#sudo ufw allow from 192.168.1.0/24 to any app Clementine
#sudo ufw allow from 192.168.1.0/24 to any app UMS
#sudo ufw allow from 192.168.1.0/24 to any app MPD
#sudo ufw allow from 192.168.1.0/24 to any app VLC_HTTP
#sudo ufw allow from 192.168.1.0/24 to any app VLC_RTP
#sudo ufw allow from 192.168.1.0/24 to any app VLC_UDP
#sudo ufw allow from 192.168.1.0/24 to any app VNC
#sudo ufw allow from 192.168.1.0/24 to any app WWW_Cache


##########################################################
# Internet Exposed Games
##########################################################
#sudo ufw allow Quake2
#sudo ufw allow Blizzard
#sudo ufw allow D2X-XL
#sudo ufw allow FreeSpace_2
#sudo ufw allow Freeciv
#sudo ufw allow Mechwarrior_4
#sudo ufw allow out Minecraft
#sudo ufw allow in Minecraft
#sudo ufw allow Steam
#sudo ufw allow Doom
#sudo ufw allow UFOAI
#sudo ufw allow DOSBox_IPX
#sudo ufw allow DOSBox_Modem

##########################################################
# Instant messaging
# You do NOT need inbound unless you are running a server!
##########################################################
#sudo ufw allow out AIM
#sudo ufw allow out Bonjour
#sudo ufw allow out MSN
#sudo ufw allow out TeamSpeak_3
#sudo ufw allow out XMPP
#sudo ufw allow out Yahoo
#sudo ufw allow out Skype
#sudo ufw allow out IRC

##########################################################
# My Outbound ONLY Traffic
##########################################################
#sudo ufw allow out DNS 
#sudo ufw allow out SSH
#sudo ufw allow out time

##########################################################
# And close up everything else
# This is last because UFW evaluates from top to bottom.  ALWAYS.
# So if you put these first (as some guides have you do) or worse,
# put "deny in to any" as your first rule, then you're borked.
# Putting your DEFAULTS like this, though, means they're evaluated last,
# which is our desired behavior - and lets us add rules later easily.
##########################################################
sudo ufw default reject incoming
sudo ufw default allow outgoing

sudo ufw enable