#!/bin/sh

pkg install -y nvidia-driver

pw groupmod video -m gael

sysrc kld_list=nvidia-modeset
