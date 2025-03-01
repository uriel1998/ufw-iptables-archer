#!/bin/bash

#################################################################################
#
# This utility is to be able to easily and quickly configure UFW
# by Steven Saus
#
# Licensed under a MIT License
#
# Requires: UFW, iptables
# References: 
# http://jhansonxi.blogspot.com/2010/10/ufw-application-profiles.html
#
# TODO: grep output to remove old versions of rules
# TODO: Allow for more user input and selection of rulesets
################################################################################

scratch=$(tempfile)

################################################################################
# Because otherwise this is a pain
################################################################################

echo "Did you run this script with sudo privileges? If not, Ctrl-C."
echo "Otherwise, press any key to continue."
read

################################################################################
# To reset
################################################################################
sudo ufw disable
echo y | sudo ufw reset > $scratch

################################################################################
# To keep backups from getting out of control; we'll rotate them like logfiles 
# here. The scratch file has the output lines from ufw reset:
#
# Resetting all rules to installed defaults. Proceed with operation (y|n)? Backing up 'user.rules' to '/lib/ufw/user.rules.20160522_142219'
# Backing up 'after6.rules' to '/etc/ufw/after6.rules.20160522_142219'
# 
# etc. This bit here will find them and compress/rotate them.
################################################################################

while IFS='' read -r line || [[ -n "$line" ]]; do
    killold=`echo ${line%?} | awk -F "to \'" '{ print $1 }'`
        
done < "$scratch"

# do stuff here

rm $scratch

################################################################################
# PulseAudio RTP Multicast
# Only enable these if you need them for recieving multicast.
# Please note rules below that also need to be enabled.
# These must go first.
################################################################################
# sudo iptables -A ufw-before-input -p igmp -d 224.0.0.0/4 -j ACCEPT
# sudo iptables -A ufw-before-output -p igmp -d 224.0.0.0/4 -j ACCEPT

################################################################################
# These are from my update_ipblock script. Comment out if
# you are not using it.
################################################################################
sudo iptables -A FORWARD -m set --match-set evil_ips src -j DROP
sudo iptables -A INPUT -m set --match-set evil_ips src -j DROP

################################################################################
# Internet Exposed Apps
################################################################################
#sudo ufw allow Icecast
#sudo ufw allow Icecast-SHOUTcast
#sudo ufw allow Crashplan
#sudo ufw allow Deluge

################################################################################
# Email - you should NOT have to use this unless you are directly having mail 
# come to you.
################################################################################
#sudo ufw allow Postfix
#sudo ufw allow Postfix_SMTPS
#sudo ufw allow Postfix_Submission

################################################################################
# LAN Services
# Obviously, change the LAN netmask based on your setup
################################################################################
sudo ufw allow from 192.168.1.0/24 to any app WoL
sudo ufw allow from 192.168.1.0/24 to any app CUPS
sudo ufw allow proto tcp from 192.168.1.0/24 to any port 21
sudo ufw allow in from 192.168.1.0/24 to any app OpenSSH
sudo ufw allow from 192.168.1.0/24 to any app Telnet
#sudo ufw allow from 192.168.1.0/24 to any app Synergy

################################################################################
# LAN File Transfer
# Obviously, change the LAN netmask based on your setup
################################################################################
#sudo ufw allow from 192.168.1.0/24 to any app BTSync
#sudo ufw allow from 192.168.1.0/24 to any app Dukto
sudo ufw allow from 192.168.1.0/24 to any app SyncThing
sudo ufw allow from 192.168.1.0/24 to any app Dropbox
sudo ufw allow from 192.168.1.0/24 to any app Samba
sudo ufw allow proto tcp from 192.168.1.0/24 to any port 20

################################################################################
# LAN Email Related
# Obviously, change the LAN netmask based on your setup
################################################################################
sudo ufw allow from 192.168.1.0/24 to any app Dovecot_IMAP
sudo ufw allow from 192.168.1.0/24 to any app Dovecot_POP3
sudo ufw allow from 192.168.1.0/24 to any app Dovecot_IMAPS
sudo ufw allow from 192.168.1.0/24 to any app Dovecot_POP3S

################################################################################
# LAN Webserver/Database
# Obviously, change the LAN netmask based on your setup
################################################################################
#sudo ufw allow from 192.168.1.0/24 to any app MySQL
sudo ufw allow from 192.168.1.0/24 to any app WWW
sudo ufw allow from 192.168.1.0/24 to any app WWW_Secure        

################################################################################
# LAN Random Applications; Way too many things use 8000 or 8080
# Obviously, change the LAN netmask based on your setup
################################################################################
sudo ufw allow from 192.168.1.0/24 to any port 8000
sudo ufw allow from 192.168.1.0/24 to any port 8080

################################################################################
# LAN Media
################################################################################
#sudo ufw allow from 192.168.1.0/24 to any app VLC_HTTP
#sudo ufw allow from 192.168.1.0/24 to any app VLC_RTP
#sudo ufw allow from 192.168.1.0/24 to any app VLC_UDP
sudo ufw allow from 192.168.1.0/24 to any app Avahi
#sudo ufw allow from 192.168.1.0/24 to any app Clementine
sudo ufw allow from 192.168.1.0/24 to any app MPD
#sudo ufw allow from 192.168.1.0/24 to any app UMS
sudo ufw allow from 192.168.1.0/24 to any app VNC

################################################################################
# PulseAudio RTP Multicast
# Please note iptables rules above
################################################################################
#sudo ufw allow in proto udp from 224.0.0.0/4
#sudo ufw allow in proto udp to 224.0.0.0/4

################################################################################
# Internet Exposed Games
################################################################################
sudo ufw allow Freeciv
sudo ufw allow Quake
sudo ufw allow Quake2
sudo ufw allow QuakeLive
sudo ufw allow AIWar
sudo ufw allow Blizzard
sudo ufw allow D2X-XL
sudo ufw allow Doom
sudo ufw allow DOSBox_IPX
sudo ufw allow DOSBox_Modem
sudo ufw allow FreeSpace_2
sudo ufw allow in Minecraft
sudo ufw allow Mechwarrior_4
sudo ufw allow out Minecraft
sudo ufw allow ProjectZomboid
sudo ufw allow Steam
sudo ufw allow UFOAI
sudo ufw allow WarcraftIII_all

################################################################################
# Instant messaging
# You do NOT need inbound unless you are running a server!
################################################################################
#sudo ufw allow out AIM
#sudo ufw allow out Bonjour
#sudo ufw allow out MSN
#sudo ufw allow out TeamSpeak3
#sudo ufw allow out TeamSpeak3_file
#sudo ufw allow out TeamSpeak3_query
#sudo ufw allow out XMPP
#sudo ufw allow out Yahoo
#sudo ufw allow out Skype
#sudo ufw allow out IRC

################################################################################
# My Outbound ONLY Traffic
################################################################################
sudo ufw allow out DNS 
sudo ufw allow out SSH
sudo ufw allow out time

################################################################################
# And close up everything else
# This is last because UFW evaluates from top to bottom.  ALWAYS.
# So if you put these first (as some guides have you do) or worse,
# put "deny in to any" as your first rule, then you're borked.
# Putting your DEFAULTS like this, though, means they're evaluated last,
# which is our desired behavior - and lets us add rules later easily.
################################################################################
sudo ufw default reject incoming
sudo ufw default allow outgoing

sudo ufw enable
