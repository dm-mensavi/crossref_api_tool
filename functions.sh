#!/bin/bash

# Function to show a progress bar in the terminal
show_loading() {
    local pid=$!
    local delay=0.20  # Time between updates (in seconds)
    local max=100     # Maximum progress value
    local width=50    # Width of the progress bar in characters
    local i=0

    echo -n "Fetching data: [          ]  0%" >&2 # Initial message to stderr (terminal)

    while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
        # Calculate percentage and bar fill
        i=$((i + 1))
        local percent=$((i * 100 / (max / 2))) # Simulate progress (adjust divisor for speed)
        if [ $percent -gt 100 ]; then percent=100; fi
        local filled=$((width * percent / 100))
        local empty=$((width - filled))

        # Build the progress bar
        local bar=$(printf "%${filled}s" | tr ' ' '#')
        bar+=$(printf "%${empty}s" | tr ' ' ' ')

        # Display the progress bar
        echo -ne "\rFetching data: [$bar] ${percent}%" >&2 # Overwrite line in terminal
        sleep $delay
    done

    # Ensure it reaches 100% when done
    local bar=$(printf "%${width}s" | tr ' ' '#')
    echo -e "\rFetching data: [$bar] 100% - Done!" >&2 # Final message with newline
}

# Function to validate DOI format (basic check, case-insensitive)
validate_doi() {
    local doi=$(echo "$1" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
    if [[ "$doi" =~ ^10\.[0-9]{4,}/.+ ]]; then
        return 0 # Valid DOI
    else
        echo "Invalid DOI format. Example: 10.1000/xyz123" >&2 # Terminal output
        return 1
    fi
}

# Function to retrieve article information by DOI
get_article_by_doi() {
    local doi=$(echo "$1" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
    local api_url="https://api.crossref.org/works/$doi"

    # Fetch data in background to show progress bar in terminal
    curl -s "$api_url" > /tmp/api_response.json &
    show_loading

    local response=$(cat /tmp/api_response.json)
    rm -f /tmp/api_response.json

    if [ -z "$response" ] || echo "$response" | grep -q "Not Found"; then
        echo "Error: No data found for DOI $doi." >&2 # Terminal output
        return 1
    fi

    # Extract fields using jq
    local title=$(echo "$response" | jq -r '.message.title[0] // "N/A"')
    local volume=$(echo "$response" | jq -r '.message.volume // "N/A"')
    local url=$(echo "$response" | jq -r '.message.URL // "N/A"')
    local doi=$(echo "$response" | jq -r '.message.DOI // "N/A"')
    local article_number=$(echo "$response" | jq -r '.message["article-number"] // "N/A"')
    local pages=$(echo "$response" | jq -r '.message.page // "N/A"')
    local journal=$(echo "$response" | jq -r '.message["container-title"][0] // "N/A"')
    local publisher=$(echo "$response" | jq -r '.message.publisher // "N/A"')
    local authors=$(echo "$response" | jq -r '.message.author[] | "\(.given) \(.family)"' 2>/dev/null | paste -sd ", " - || echo "N/A")
    local year=$(echo "$response" | jq -r '.message.issued["date-parts"][0][0] // "N/A"')
    local bibtex_key=$(echo "$response" | jq -r '.message["short-container-title"][0] // "N/A"')

    # Format output with timestamp
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local output="Search Date: $timestamp
Title: $title
Volume: $volume
URL: $url
DOI: $doi
Article Number: $article_number
Pages: $pages
Journal: $journal
Publisher: $publisher
Authors: $authors
Year of Publication: $year
Bibtex Key: $bibtex_key
------------------"

    # Append to search_history.txt and return output
    echo "$output" >> "$SEARCH_HISTORY_FILE" # Append to file
    echo "$output" # Return for display
}

# Function to search articles by title or author
search_articles() {
    local query_type=$1
    local query=$(echo "$2" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
    local api_url="https://api.crossref.org/works?query.$query_type=$query&rows=10"

    # Fetch data in background to show progress bar in terminal
    curl -s "$api_url" > /tmp/api_response.json &
    show_loading

    local response=$(cat /tmp/api_response.json)
    rm -f /tmp/api_response.json

    if [ -z "$response" ] || echo "$response" | grep -q "Not Found"; then
        echo "Error: No results found for $query_type '$query'." >&2 # Terminal output
        return 1
    fi

    # Extract list of articles
    local items=$(echo "$response" | jq -r '.message.items[] | "\(.DOI) - \(.title[0])"' 2>/dev/null)
    if [ -z "$items" ]; then
        echo "No articles found." >&2 # Terminal output
        return 1
    fi

    # Let user select an article using Rofi with direct input
    local selected_item=$(echo "$items" | rofi -dmenu -config "$CONFIG_FILE" -p "Select an article:" -width 50 -lines 10 -i)
    if [ -z "$selected_item" ]; then
        echo "No article selected." >&2 # Terminal output
        return 1
    fi

    local selected_doi=$(echo "$selected_item" | cut -d' ' -f1)
    get_article_by_doi "$selected_doi"
}