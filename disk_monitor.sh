#!/bin/bash

usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $usage -gt 10 ]; then 
	echo "Disk space almost full $usage% used."
fi
