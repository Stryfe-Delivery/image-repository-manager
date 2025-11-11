#!/bin/bash

# Function to check and install ffmpeg if needed
ensure_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        echo "Installing ffmpeg..."
        sudo apt update
        sudo apt install -y ffmpeg
        echo "ffmpeg installation complete."
    else
        echo "ffmpeg is already installed."
    fi
}

# Function to validate if file is a valid image
is_valid_image() {
    local file="$1"
    
    # Use file command to check the actual file type
    local file_type
    file_type=$(file -b "$file" 2>/dev/null)
    
    # Check if it's a valid image file
    if [[ "$file_type" =~ (JPEG|PNG|JPEG image|PNG image) ]]; then
        return 0
    else
        echo "Warning: '$file' may not be a valid image file (detected as: $file_type)"
        return 1
    fi
}

# Function to check if file needs conversion
should_convert() {
    local file="$1"
    
    # Check if file has one of the target suffixes
    if [[ "$file" =~ -[0-9]{3}\.(jpg|jpeg|png)$ ]]; then
        return 1
    fi
    
    # Check if all output files already exist
    local base="${file%.*}"
    local ext="${file##*.}"
    local lower_ext="${ext,,}"
    
    if [[ -f "${base}-400.${lower_ext}" && -f "${base}-800.${lower_ext}" && -f "${base}-1200.${lower_ext}" ]]; then
        return 1
    fi
    
    return 0
}

# Function to convert a single image
convert_image() {
    local input_file="$1"
    local base="${input_file%.*}"
    local ext="${input_file##*.}"
    local lower_ext="${ext,,}"
    
    echo "Processing: $input_file"
    
    # Create the three resized versions with better error handling
    if ffmpeg -i "$input_file" -vf "scale='min(480,iw)':-1" "${base}-400.${lower_ext}" -nostdin -loglevel error 2>/dev/null; then
        echo "  Created: ${base}-400.${lower_ext}"
    else
        echo "  Failed to create: ${base}-400.${lower_ext}"
        # Remove any partial output file
        [ -f "${base}-400.${lower_ext}" ] && rm "${base}-400.${lower_ext}"
    fi
    
    if ffmpeg -i "$input_file" -vf "scale='min(720,iw)':-1" "${base}-800.${lower_ext}" -nostdin -loglevel error 2>/dev/null; then
        echo "  Created: ${base}-800.${lower_ext}"
    else
        echo "  Failed to create: ${base}-800.${lower_ext}"
        [ -f "${base}-800.${lower_ext}" ] && rm "${base}-800.${lower_ext}"
    fi
    
    if ffmpeg -i "$input_file" -vf "scale='min(1280,iw)':-1" "${base}-1200.${lower_ext}" -nostdin -loglevel error 2>/dev/null; then
        echo "  Created: ${base}-1200.${lower_ext}"
    else
        echo "  Failed to create: ${base}-1200.${lower_ext}"
        [ -f "${base}-1200.${lower_ext}" ] && rm "${base}-1200.${lower_ext}"
    fi
}

# Main script execution
main() {
    echo "Starting image conversion process..."
    
    # Ensure ffmpeg is available
    ensure_ffmpeg
    
    # Process image files
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            if should_convert "$file"; then
                if is_valid_image "$file"; then
                    convert_image "$file"
                else
                    echo "Skipping invalid image: $file"
                fi
            else
                echo "Skipping: $file (already converted or is a target file)"
            fi
        fi
    done < <(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)
    
    echo "Image conversion process completed."
}

# Run the main function
main
