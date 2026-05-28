#!/bin/bash

set -euo pipefail

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
downloads=(
	"pedos.gz|http://list.iblocklist.com/?list=dufcxgnbjsdwmwctgfuj&fileformat=p2p&archiveformat=gz"
	"ads.gz|http://list.iblocklist.com/?list=dgxtneitpuvgqqcpfulq&fileformat=p2p&archiveformat=gz"
	"spyware.gz|http://list.iblocklist.com/?list=llvtlsjyoyiczbkjsxpf&fileformat=p2p&archiveformat=gz"
	"hijacked.gz|http://list.iblocklist.com/?list=usrcshglbiilevmyfhse&fileformat=p2p&archiveformat=gz"
	"exploit.gz|http://list.iblocklist.com/?list=ghlzqtqxnzctvvajwwag&fileformat=p2p&archiveformat=gz"
)
downloaded_files=()

require_command() {
	local cmd=$1

	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "Missing required command: $cmd" >&2
		exit 1
	fi
}

ensure_iptables_set_drop_rule() {
	local chain=$1

	if ! sudo iptables -C "$chain" -m set --match-set "$SETNAME" src -j DROP &>/dev/null; then
		sudo iptables -I "$chain" 2 -m set --match-set "$SETNAME" src -j DROP
	fi
}

require_command gawk
require_command gunzip
require_command ipset
require_command ionice
require_command iptables
require_command wget

mkdir -p "$workdir"
cd "$workdir" || exit 1
rm -f -- "$workdir/evil_ips.dat" "$workdir/bigfilter.raw"

########################################################################
# Download the IP filter lists. If you have an account with I-Blocklist, 
# you may have more options; these are the public links
#
# We are only downloading "evil" ones - associated with child porn,
# spyware, web exploits - stuff you just don't want.
# Obviously, you will want to comment out any you don't care about.
########################################################################

for download in "${downloads[@]}"; do
	filename=${download%%|*}
	url=${download#*|}
	if wget -O "$workdir/$filename" "$url"; then
		downloaded_files+=("$filename")
	else
		echo "Warning: failed to download $url" >&2
		rm -f -- "$workdir/$filename"
	fi
done

if [ "${#downloaded_files[@]}" -eq 0 ]; then
	echo "Unable to download any blocklists." >&2
	exit 1
fi


shopt -s nullglob

for f in *.gz; do
	gunzip -f "$f"
done

########################################################################
# Combining, cleaning, transforming the blocklists 
########################################################################

for filename in "${downloaded_files[@]}"; do
	plain_file=${filename%.gz}
	if [ ! -f "$plain_file" ]; then
		continue
	fi
	cat "$plain_file" >> "$workdir/bigfilter.raw"
	rm -f -- "$plain_file"
done

if [ ! -f "$workdir/bigfilter.raw" ]; then
	echo "Downloaded blocklists did not yield any usable data." >&2
	exit 1
fi

grep ":" "$workdir/bigfilter.raw" | gawk -F ":" '{print $2}' | sort -u > "$workdir/evil_ips.dat"
rm -f -- "$workdir/bigfilter.raw"

if [ ! -s "$workdir/evil_ips.dat" ]; then
	echo "Blocklists produced no IP ranges." >&2
	exit 1
fi

########################################################################
# Cleaning or creating the IP set, then adding the list. May take a 
# while. It echoes the IP address it's adding as it goes simply so
# you have a visual clue as to what's going on.
########################################################################

if ! sudo ipset list "$SETNAME" &>/dev/null; then
	echo "Creating IPSET list $SETNAME"
	sudo ipset create "$SETNAME" hash:net # create new IP set
else
	echo "Clearing list $SETNAME"
	sudo ipset flush "$SETNAME" # clear existing IP set
fi

ensure_iptables_set_drop_rule INPUT

echo "Adding IPs to $SETNAME"
while read -r line; do
	printf 'Adding %s\n' "$line"
	sudo ipset add "$SETNAME" "$line"
done < "$workdir"/evil_ips.dat

########################################################################
# Adding the IP set to the firewall. UNCOMMENT these two lines if you
# are not using my UFW script as well. 
########################################################################

#sudo iptables -A FORWARD -m set --match-set evil_ips src -j DROP
#sudo iptables -A INPUT -m set --match-set evil_ips src -j DROP
