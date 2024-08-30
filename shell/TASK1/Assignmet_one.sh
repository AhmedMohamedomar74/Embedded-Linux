#!/usr/bin/bash

# Directory to list (you can change this to any directory path)
directory="/home/ahmedomar/Downloads/bash/Assignment_1_directory"

# make an array that store all name of files
all_file=()

# Loop through each file in the directory
for file in "$directory"/*; do
    # Check if it's a file (not a directory)
    if [ -f "$file" ]; then
        all_file+=("$file")
    fi
done

for file in ${all_file[@]}; do
    extension="${file##*.}"
    case "${extension}" in
        pdf)
            mv "${file}" /home/ahmedomar/Downloads/bash/Assignment_1_directory/pdf
            ;;
        txt)
            mv "${file}" /home/ahmedomar/Downloads/bash/Assignment_1_directory/txt
            ;;
        jpg)
            mv "${file}" /home/ahmedomar/Downloads/bash/Assignment_1_directory/jpg
            ;;
        *)
            mv "${file}" /home/ahmedomar/Downloads/bash/Assignment_1_directory/music
            ;;    
    esac 
done