#!/bin/bash

# Default mode
MODE="validate"
EXTENSIONS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--download)
        MODE="download"
        shift
        ;;
        -v|--validate)
        MODE="validate"
        shift
        ;;
        *)
        EXTENSIONS+=("$1")
        shift
        ;;
    esac
done

# Default list if no extensions provided
if [ ${#EXTENSIONS[@]} -eq 0 ]; then
    EXTENSIONS=("betterthantomorrow.calva")
fi

# Function to get extension data (Version and URL)
get_extension_data() {
    local full_id="$1"
    
    # Send POST request to Marketplace API
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json;api-version=3.0-preview.1" \
        -d "{\"filters\":[{\"criteria\":[{\"filterType\":7,\"value\":\"$full_id\"}]}],\"flags\":914}" \
        "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery")

    # Extract Version and URL
    # Returns: VERSION URL
    echo "$response" | jq -r '.results[0].extensions[0].versions[0] | "\(.version) \(.files[] | select(.assetType == "Microsoft.VisualStudio.Services.VSIXPackage") | .source)"'
}

validate_url() {
    local url="$1"
    if [[ -z "$url" || "$url" == "null" ]]; then
        echo "Error: Could not retrieve URL. Extension might not exist."
        return 1
    fi

    echo "Checking URL..."
    if curl --output /dev/null --silent --head --fail "$url"; then
        echo "URL is VALID."
        return 0
    else
        echo "URL is INVALID."
        return 1
    fi
}

download_file() {
    local url="$1"
    local filename="$2"
    
    if [[ -z "$url" || "$url" == "null" ]]; then
        echo "Error: Invalid URL."
        return 1
    fi

    echo "Downloading to $filename..."
    curl -L -o "$filename" "$url"
    
    if [ $? -eq 0 ]; then
        echo "Download complete."
    else
        echo "Download failed."
    fi
}

# Main execution
for ext in "${EXTENSIONS[@]}"; do
    echo "Processing extension: $ext"
    
    # Read data into variables
    read -r version url <<< "$(get_extension_data "$ext")"
    
    if [[ -z "$version" || "$url" == "null" ]]; then
        echo "Failed to fetch metadata for $ext"
        echo "-----------------------------------"
        continue
    fi
    
    echo "Found version: $version"
    echo "URL: $url"

    if [ "$MODE" == "download" ]; then
        filename="${ext}-${version}.vsix"
        download_file "$url" "$filename"
    else
        validate_url "$url"
    fi
    echo "-----------------------------------"
done
