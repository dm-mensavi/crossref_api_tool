#!/bin/bash

# Define paths
CONFIG_FILE="./config.rasi"
SEARCH_HISTORY_FILE="./search_history.txt"

# Source the functions file
if [ ! -f "./functions.sh" ]; then
    echo "Error: functions.sh not found!" >&2 # Terminal output
    exit 1
fi
source ./functions.sh

# Function to handle post-result actions
handle_result() {
    local result="$1"
    local options=("Copy All Details" "Restart Search" "Exit")
    local action=$(echo -e "Article Details:\n$result\n\nSelect an action:\n$(printf '%s\n' "${options[@]}")" | rofi -dmenu -config "$CONFIG_FILE" -p "Result" -width 50 -lines 15)

    case "$action" in
        "Copy All Details")
            echo -n "$result" | xclip -selection clipboard
            echo "Details copied to clipboard!" >&2 # Terminal output
            handle_result "$result" # Recursive call to show options again
            ;;
        "Restart Search")
            main_menu
            ;;
        "Exit")
            echo "Goodbye!" >&2 # Terminal output
            exit 0
            ;;
        *)
            echo "No action selected." >&2 # Terminal output
            handle_result "$result" # Recursive call if no valid action
            ;;
    esac
}

# Main menu loop
main_menu() {
    while true; do
        options=("Search by Title" "Search by Author" "Search by DOI" "Exit")
        # Use -no-custom to disable the search field in the main menu
        selected_option=$(printf "%s\n" "${options[@]}" | rofi -dmenu -config "$CONFIG_FILE" -p "Crossref API Tool" -width 30 -lines 4 -no-custom)

        case "$selected_option" in
            "Search by Title")
                query=$(rofi -dmenu -config "$CONFIG_FILE" -p "Enter article title:" -width 40)
                if [ -n "$query" ]; then
                    result=$(search_articles "title" "$query")
                    if [ $? -eq 0 ]; then
                        handle_result "$result"
                    fi
                else
                    echo "No title entered." >&2 # Terminal output
                fi
                ;;
            "Search by Author")
                query=$(rofi -dmenu -config "$CONFIG_FILE" -p "Enter author name:" -width 40)
                if [ -n "$query" ]; then
                    result=$(search_articles "author" "$query")
                    if [ $? -eq 0 ]; then
                        handle_result "$result"
                    fi
                else
                    echo "No author name entered." >&2 # Terminal output
                fi
                ;;
            "Search by DOI")
                doi=$(rofi -dmenu -config "$CONFIG_FILE" -p "Enter DOI:" -width 40)
                if [ -n "$doi" ] && validate_doi "$doi"; then
                    result=$(get_article_by_doi "$doi")
                    if [ $? -eq 0 ]; then
                        handle_result "$result"
                    fi
                else
                    echo "No DOI entered or invalid format." >&2 # Terminal output
                fi
                ;;
            "Exit")
                echo "Goodbye!" >&2 # Terminal output
                exit 0
                ;;
            *)
                echo "Invalid option." >&2 # Terminal output
                ;;
        esac
        read -p "Press Enter to continue..." >&2 # Terminal prompt
    done
}

# Check dependencies
for cmd in curl jq rofi xclip; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it." >&2 # Terminal output
        exit 1
    fi
done

# Start the script
echo "Welcome to the Crossref API Tool!" >&2 # Terminal output
main_menu