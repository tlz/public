#!/bin/sh

cat > /etc/sysconfig/iptables <<EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [2350:304457]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m tcp -i lo -s 127.0.0.1 -j ACCEPT
-A INPUT -p icmp -j ACCEPT
COMMIT
EOF

/sbin/chkconfig iptables on
/sbin/service iptables restart
exit 0
