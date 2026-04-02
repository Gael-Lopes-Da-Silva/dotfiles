#!/usr/bin/env bash

if [[ "$1" == "-s" ]]; then
    yes "click left" | dotool
fi

exit 0
