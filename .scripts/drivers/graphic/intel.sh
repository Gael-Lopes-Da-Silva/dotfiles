#!/bin/sh

pkg install -y drm-kmod

pw groupmod video -m gael

sysrc kld_list=i915kms
