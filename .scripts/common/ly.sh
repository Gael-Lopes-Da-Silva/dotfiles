#!/bin/sh

pkg install -y ly

echo "Ly:\\" >> /etc/gettytab
echo "        :lo=/usr/local/bin/ly:\\" >> /etc/gettytab
echo "        :al=root:" >> /etc/gettytab

vi /etc/ttys # replace ttyv1 greeter
