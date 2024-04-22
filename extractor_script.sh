#!/bin/bash
# this script aims to extract the relevant question ofr each student from nested zip files and later to rename the ..py file of that question 
#to put it in a folder. 

#change the paths in lines 4 and 5
#change the question name in lines 30 and 53

#paths
submission_dir="/mnt/c/Users/eracvd/Desktop/Class/comp125-spring24/hw2-q4/section4" # folder for each section
output_dir="/mnt/c/Users/eracvd/Desktop/Class/comp125-spring24/hw2-q4/output-4" # will move to this fodler 

mkdir -p "$output_dir"

extract_files() {
    local file_path=$1
    local student_id=$2
    local temp_dir=$(mktemp -d)

    case "$file_path" in
        *.zip)
            unzip -q "$file_path" -d "$temp_dir"
            ;;
        *.rar)
            unrar x -inul "$file_path" "$temp_dir"
            ;;
    esac

    find "$temp_dir" -type f \( -iname '*.zip' -or -iname '*.rar' \) -exec bash -c 'extract_files "{}" "$0"' "$student_id" \;

    local rps_file=$(find "$temp_dir" -type f -iname 'RockPaperScissors.py')
    if [[ -n "$rps_file" ]]; then
        cp "$rps_file" "$output_dir/RockPaperScissors_${student_id}.py" #change question name here
    fi

    rm -rf "$temp_dir"
}

for file in "$submission_dir"/*.{zip,rar}; do
    [[ -e $file ]] || continue

    # student ID from the file name
    filename=$(basename "$file")
    student_id=$(echo "$filename" | grep -oP '(?<=_)[^_]+(?=_attempt)')

    extract_files "$file" "$student_id"  #inner zips and rars
done

for py_file in "$submission_dir"/*RockPaperScissors.py; do
    [[ -e $py_file ]] || continue

    filename=$(basename "$py_file")
    student_id=$(echo "$filename" | grep -oP '(?<=_)[^_]+(?=_attempt)')

    # Rename and move the Python file
    cp "$py_file" "$output_dir/RockPaperScissors_${student_id}.py" #change question name here
done

echo "Extraction and renaming complete. Files are available in $output_dir."