#!/bin/sh

pkg install -y ly

echo "Ly:\\" >> /etc/gettytab
echo "        :lo=/usr/local/bin/ly:\\" >> /etc/gettytab
echo "        :al=root:" >> /etc/gettytab

echo "/etc/ttys"
echo "ttyv1    \"/usr/libexec/getty Ly\"         xterm  on secure"
