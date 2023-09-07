#!/bin/sh

# Get some parameters like the location and the school to be used
# when calculating the fajr and isha angle
today=$(date +%s)
lat='30.001780'
long='31.290419'
city="Cairo"
country="Egypt"
method="5" # https://api.aladhan.com/v1/methods
adjustment="0"
output="$HOME/.local/share/prayers.json"

# http://api.aladhan.com/v1/timingsByCity/:date - for city names instead of coordinates
# Example: http://api.aladhan.com/v1/timingsByCity/$today?city=$city&country=$country
wget -O $output "http://api.aladhan.com/v1/timings/$today?latitude=$lat&longitude=$long&method=$method&adjustment=$adjustment"

echo "Creating at jobs for prayer notification..."

$HOME/.local/bin/add-prayers-at-jobs.sh
