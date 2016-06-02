#!/bin/bash 

########################################################################
# This is a script to automate the downloading, cleaning, and 
# implementation of blocklists for IPTABLES to protect your 
# computer or server from IPs associated with bad things like 
# malware, child pornography, web exploits, and the like.
# It can be used without my UFW script, but you'll want to uncomment
# the last two lines.
#
# by Steven Saus
#
# Licensed under a MIT License
#
# References: http://kirkkosinski.com/2013/11/mass-blocking-evil-ip-addresses-iptables-ip-sets/
#
# Requires: IPSET, which is probably available from your distro
########################################################################

########################################################################
# Changing this process to idle io priority
# Reference: https://friedcpu.wordpress.com/2007/07/17/why-arent-you-using-ionice-yet/
########################################################################
ionice -c3 -p$$


########################################################################
# Initializing 
########################################################################

SETNAME="evil_ips"
workdir="$HOME/.config/evil_ip"

if [ ! -d "$workdir"]; then
	mkdir "$workdir"
fi	
cd "$workdir"

if [ -f "$workdir"/evil_ips.dat ]; then
	rm -f "$workdir"/evil_ips.dat
fi

cd "$workdir"

########################################################################
# Download the IP filter lists. If you have an account with I-Blocklist, 
# you may have more options; these are the public links
#
# We are only downloading "evil" ones - associated with child porn,
# spyware, web exploits - stuff you just don't want.
# Obviously, you will want to comment out any you don't care about.
########################################################################

#Pedos
wget -O "$workdir"/pedos.gz "http://list.iblocklist.com/?list=dufcxgnbjsdwmwctgfuj&fileformat=p2p&archiveformat=gz"
#ads
wget -O "$workdir"/ads.gz "http://list.iblocklist.com/?list=dgxtneitpuvgqqcpfulq&fileformat=p2p&archiveformat=gz"
#spyware
wget -O "$workdir"/spyware.gz "http://list.iblocklist.com/?list=llvtlsjyoyiczbkjsxpf&fileformat=p2p&archiveformat=gz"
#hijacked
wget -O "$workdir"/hijacked.gz "http://list.iblocklist.com/?list=usrcshglbiilevmyfhse&fileformat=p2p&archiveformat=gz"
#webexploit
wget -O "$workdir"/exploit.gz "http://list.iblocklist.com/?list=ghlzqtqxnzctvvajwwag&fileformat=p2p&archiveformat=gz"


shopt -s nullglob

for f in *.gz; do gunzip -f $f;done

for f in *.gz;do rm -f $f;done

########################################################################
# Combining, cleaning, transforming the blocklists 
########################################################################

for file in *; do                                                                                   
	test "${file%.*}" = "$file" && cat "$file" >> "$workdir"/bigfilter.raw;
	rm "$file";                                           
done

cat "$workdir"/bigfilter.raw | grep ":" | gawk -F ":" '{print $2}' |sort | uniq |sort > "$workdir"/evil_ips.dat
rm "$workdir"/bigfilter.raw

########################################################################
# Cleaning or creating the IP set, then adding the list. May take a 
# while. It echoes the IP address it's adding as it goes simply so
# you have a visual clue as to what's going on.
########################################################################

sudo ipset list $SETNAME &>/dev/null # check if the IP set exists
if [ $? -ne 0 ]; then
	echo "Creating IPSET list $SETNAMES"
	sudo ipset create $SETNAME hash:net # create new IP set
	sudo iptables -I INPUT 2 -m set --match-set $SETNAME src -j DROP
else
	echo "Clearing list $SETNAME"
	sudo ipset flush $SETNAME # clear existing IP set
fi

echo "Adding IPs to $SETNAME"
while read line;do
	printf "Adding $line \n"
	sudo ipset add evil_ips "$line"
done < "$workdir"/evil_ips.dat

########################################################################
# Adding the IP set to the firewall. UNCOMMENT these two lines if you
# are not using my UFW script as well. 
########################################################################

#sudo iptables -A FORWARD -m set --match-set evil_ips src -j DROP
#sudo iptables -A INPUT -m set --match-set evil_ips src -j DROP