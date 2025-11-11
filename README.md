# Image Resizer Script for Raspberry Pi OS

A robust shell script for batch resizing images to multiple dimensions while maintaining aspect ratios. Perfect for creating responsive image sets for web development or photo galleries.

## Features

-  **Batch Processing**: Automatically processes all JPG, JPEG, and PNG files in a directory
-  **Smart Resizing**: Creates three resized versions (480px, 720px, 1280px max dimension) while maintaining aspect ratios
-  **Duplicate Protection**: Skips already processed files and prevents re-processing of output files
-  **File Validation**: Automatically detects and skips corrupted or invalid image files
-  **Format Preservation**: Maintains original file formats with proper case handling
-  **Auto Dependency Management**: Automatically checks for and installs FFmpeg if needed

## Requirements

- Raspberry Pi OS (latest recommended)
- Internet connection (for initial FFmpeg installation)

## Installation

1. **Download the script**:
   ```bash
   wget https://raw.githubusercontent.com/Stryfe-Delivery/image-repository-manager/image-converter.sh
   ```

2. **Make it executable**:
   ```bash
   chmod +x image-converter.sh
   ```

3. **Run directly** or move to a directory in your PATH:
   ```bash
   # For system-wide access:
   sudo mv image-converter.sh /usr/local/bin/image-resizer
   ```

## Usage

### Basic Usage
```bash
# Navigate to your image directory
cd /path/to/your/images

# Run the script
./image-converter.sh
```

### What It Does
For each valid image file (e.g., `photo.jpg`), the script creates three resized copies:
- `photo-400.jpg` (480px max dimension)
- `photo-800.jpg` (720px max dimension) 
- `photo-1200.jpg` (1280px max dimension)

Original files are never modified or deleted.

## File Validation

The script includes built-in file validation that automatically detects and skips:
- Corrupted image files
- Files with incorrect extensions
- Non-image files with image extensions

### Manual File Validation Check

If you want to manually check for invalid PNG files before running the script, use this grep command:

```bash
# Check for invalid PNG files in the current directory
file *.png */*.png 2>/dev/null | grep -v "PNG image"

# For a more comprehensive check including all image types:
find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -exec file {} \; | grep -vE "(JPEG image|PNG image|JPEG|PNG)"
```

#### Understanding the Grep Check

```bash
file *.png */*.png 2>/dev/null | grep -v "PNG image"
```

- `file *.{png,PNG}`: Uses the `file` command to detect actual file types (not just extensions)
- `2>/dev/null`: Suppresses error messages for non-existent files
- `grep -v "PNG image"`: Shows only files that are **NOT** valid PNG images
- The `-v` flag inverts the match, displaying lines that don't contain "PNG image"

This helps identify files that have `.png` extensions but aren't actually valid PNG images, which could cause processing errors.

## Output Examples

**Input files:**
```
vacation.jpg
family.png
document.pdf  # Skipped - not an image
corrupted.png # Skipped - invalid image file
```

**Output files:**
```
vacation.jpg          # Original preserved
vacation-400.jpg      # 480px max dimension
vacation-800.jpg      # 720px max dimension  
vacation-1200.jpg     # 1280px max dimension
family.png            # Original preserved
family-400.png        # 480px max dimension
family-800.png        # 720px max dimension
family-1200.png       # 1280px max dimension
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x image-converter.sh
   ```

2. **FFmpeg Installation Fails**
   ```bash
   sudo apt update && sudo apt install ffmpeg
   ```

3. **Invalid PNG Files**
   - Use the grep check above to identify problematic files
   - Consider re-downloading or re-saving corrupted images

4. **Script Not Found**
   ```bash
   # Ensure you're in the correct directory or use full path
   /path/to/script/image-converter.sh
   ```

### Logging

The script provides detailed output showing:
- Which files are being processed
- Which files are skipped (already processed or invalid)
- Success/failure status for each conversion
- Warnings for invalid image files

## Customization

You can modify the script to change:
- Output dimensions (edit the `convert_image` function)
- File suffixes (update the `-400`, `-800`, `-1200` patterns)
- Supported file types (modify the `find` command patterns)
These patterns are specficially needed for a website hosting repo being devloped. 

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Ensure all files have correct permissions
3. Verify FFmpeg is properly installed: `ffmpeg -version`
4. Run the file validation check to identify problematic images
5. Feel free to reach out (just be patient and nice please)

---

**Note**: Always test the script on a copy of your images before processing important files.
