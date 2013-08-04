#!/bin/sh

#### iptables setup
/bin/cat > /etc/sysconfig/iptables <<EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [2350:304457]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp -i lo -s 127.0.0.1 -j ACCEPT
-A INPUT -p icmp -j ACCEPT
COMMIT
EOF

/sbin/chkconfig iptables on
/sbin/service iptables restart

#### disable password login via SSHd
/bin/ed /etc/ssh/sshd_config <<EOF
1
/^PasswordAuthentication/s/ yes/ no/
1
/^UsePAM/s/ yes/ no/
wq
EOF

/sbin/service sshd restart

exit 0
