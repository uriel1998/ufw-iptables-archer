ufw-iptables-archer
===================

Simplifying (I hope) UFW and iptables for folks and serving as a reference for myself

Beware!  You're entering the ....

![danger zone!](https://raw.githubusercontent.com/uriel1998/ufw-iptables-archer/master/dangerzone.jpg)

Everything in /applications.d goes into /etc/ufw/applications.d.  You'll need to change the owner to root. 

I've provided two scripts - comment and uncomment as needed for what you want to expose to the LAN and interwebs

Edit the rules in the LAN area to reflect the subnet of your LAN, obvs.

You can use something like my [network control manager](https://github.com/uriel1998/networkcontrol-wicd-networkmanager) to configure which script is called.