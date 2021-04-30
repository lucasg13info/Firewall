#!/bin/sh
### BEGIN INIT INFO
# Provides:          firewall.sh
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start firewall.sh at boot time
# Description:       Enable service provided by firewall.sh.
### END INIT INFO
# -------------------------------------------------------------------------
#
#  Firewall IPPBX ACOM
#  Desenvolvimento: Andre Brasil - andrebrasil@acomip.com.br
#
# -------------------------------------------------------------------------
#  Com o comando # echo "/etc/init.d/firewall.sh" >> /etc/rc.local
#  rode o comando # update-rc.d firewall.sh defaults
# -------------------------------------------------------------------------

# Limpar regras anteriores
iptables -F
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -t mangle -F
iptables -t nat -F
iptables -X

# Carregar modulos
modprobe ip_tables
modprobe iptable_nat
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
modprobe ipt_LOG
modprobe ipt_REJECT
modprobe ipt_MASQUERADE
modprobe ipt_state
modprobe ipt_multiport
modprobe iptable_mangle
modprobe ipt_tos
modprobe ipt_limit
modprobe ipt_mark
modprobe ipt_MARK

# politica padrao como DROP para FORWARD e INPUT
#iptables -P INPUT DROP
#iptables -P FORWARD DROP
#iptables -P OUTPUT ACCEPT

# liberar processos via loopback
#iptables -I INPUT -i lo -j ACCEPT
#iptables -I OUTPUT -o lo -j ACCEPT

# liberar acesso pela rede interna (Rede interna precisa ser adequada a rede do cliente)
iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT

# liberar loopback
iptables -A INPUT -i lo -j ACCEPT

# Liberar servicos

# ssh
#iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -s 177.68.78.71 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT # restrito acomip
#iptables -A INPUT -p tcp --dport 22 -s 152.249.226.85 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT # restrito acomip
iptables -A INPUT -p tcp --dport 22 -s 200.155.173.130 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT # restrito acomip
iptables -A INPUT -p tcp --dport 22 -s 189.54.220.174 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT # restrito robson
iptables -A INPUT -p tcp --dport 22 -s 177.139.12.63 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT # restrito lucas
iptables -A INPUT -p tcp --dport 22 -s 170.81.211.30 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT # restrito Karol


# web
#iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# ssl
#iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# dns
iptables -A INPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Liberar SIP
iptables -A INPUT -p udp --dport 5060 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p udp --dport 5060 -s 177.68.78.71 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT # restringir a um IP específico

#restrito IP Karol
iptables -A INPUT -p udp --dport 5060 -s 170.81.211.30 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -p tcp --dport 5060 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p udp --dport 5061 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p tcp --dport 5061 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p udp --dport 2727 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp --dport 8000:65000 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


# Liberar Openfire IM (Jabber)
#iptables -A INPUT -p tcp --dport 5222 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p udp --dport 5222 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p tcp --dport 7777 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p udp --dport 7777 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p tcp --dport 9090 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p udp --dport 9090 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p tcp --dport 9091 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p udp --dport 9091 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Liberar T38 fax
#iptables -A INPUT -p udp -m udp --dport 4000:4999 -j ACCEPT

# Liberar IAX
iptables -A INPUT -p udp --dport 4569 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# Liberar o manager do asterisk
#iptables -A INPUT -s 127.0.0.1 -p tcp --dport 5038 -j ACCEPT

# Liberar retorno de solicitacoes que ja sairam
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Liberar o acesso a internet atravédo link do PABXIP
#iptables -A FORWARD -s 192.168.0.0/24 -j ACCEPT

# Liberar ip_forward
#echo 1 > /proc/sys/net/ipv4/ip_forward

# Mascaramento de pacotes
#iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# politica padrao como DROP para FORWARD e INPUT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

service fail2ban restart

echo "Firewall carregado com sucesso";

