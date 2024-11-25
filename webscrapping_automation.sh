#!/bin/bash

# CONFIGURATION
URL="https://news.ycombinator.com/"  # Website to scrape
OUTPUT_FILE="scraped_data.csv"       # Output file to store results
PATTERN="<a href=\"item\?id=[0-9]+\" class=\"titlelink\">.*</a>"  # Regex to extract news titles

# FUNCTIONS

# Function to fetch and parse webpage content
fetch_and_parse() {
    echo "Fetching data from $URL..."
    curl -s "$URL" | grep -oP "$PATTERN" | sed -e 's/<[^>]*>//g' > temp.txt
    
    if [[ -s temp.txt ]]; then
        echo "Data fetched successfully. Processing..."
        echo "Headline,Link" > "$OUTPUT_FILE"
        while IFS= read -r line; do
            TITLE=$(echo "$line" | sed -e 's/^.*">//;s/<.*$//')
            LINK=$(echo "$line" | grep -oP '(?<=href=").+?(?=")')
            echo "\"$TITLE\",\"$LINK\"" >> "$OUTPUT_FILE"
        done < temp.txt
        echo "Results saved to $OUTPUT_FILE."
    else
        echo "Failed to fetch data or no relevant content found."
    fi
    rm -f temp.txt
}

# MAIN SCRIPT
fetch_and_parse
