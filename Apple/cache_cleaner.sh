#!/bin/bash

# Find cache directories
cache_dirs=$(find /Users/yourusername/ -type d \( -name "Caches" -o -name "cache" -o -name "tmp" -o -name  "*Cache*" \) -exec du -sh {} + 2>/dev/null | sort -rh | awk '{print $2}')

# Iterate through each cache directory and empty its contents
for dir in $cache_dirs; do
    if [ -d "$dir" ]; then  # Double-check it's a directory
        echo "Emptying cache directory: $dir"
        rm -rf "$dir"/*     # Remove all files and subdirectories within the cache directory
    fi
done
