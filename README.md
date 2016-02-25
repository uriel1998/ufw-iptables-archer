ufw-iptables-archer
===================

Simplifying (I hope) UFW and iptables for folks and serving as a reference for myself

Beware!  You're entering the ....

![danger zone!](https://raw.githubusercontent.com/uriel1998/ufw-iptables-archer/master/dangerzone.jpg)

Everything in /applications.d goes into /etc/ufw/applications.d.  You'll need to change the owner to root. 

#ufw_setup.sh

I've provided two scripts so you can easily run one depending on your location - comment and uncomment as needed for what you want to expose to the LAN and interwebs. You will need to run this with superuser rights.

Edit the rules in the LAN area to reflect the subnet of your LAN, obvs.

You can use something like my [network control manager](https://github.com/uriel1998/networkcontrol-wicd-networkmanager) to configure which script is called.

#update_ipblock.sh

 This is a script to automate the downloading, cleaning, and implementation of blocklists for IPTABLES to protect your computer or server from IPs associated with bad things like malware, child pornography, web exploits, and the like.
 
 It can be used without my UFW script, but you'll want to uncomment the last two lines. You will need to run this with superuser rights.
 
 Prerequisites: IPSET, which should be available for your distribution.
