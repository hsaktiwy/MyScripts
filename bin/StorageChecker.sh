#!/bin/bash
for file in $(ls -1); do
    #du -h "$file" | grep "$file$"
	du -h "$file" | awk '$2 !~ /\//' | sed 's/$/$/'
done
