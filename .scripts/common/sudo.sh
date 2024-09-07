#!/bin/sh

pkg install -y sudo

pw groupmod wheel -m gael

visudo # uncomment %wheel group
