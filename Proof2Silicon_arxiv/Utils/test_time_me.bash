#!/usr/bin/env bash

# 1. List your login sessions since Jan 1, 2024 (excluding those still logged in)
last -F -s 2024-01-01 "$USER" | grep -v "still logged in" > my_sessions.txt

# 2. Extract timestamps and compute session durations
awk '
  # Skip the header and empty lines
  NF > 7 {
    # Parse the date and time fields
    # Format varies but typically: username tty addr mon day time - time (duration)
    # Example: user pts/0 ip-address Mon Jan 1 09:15:30 2024 - Mon Jan 1 17:30:45 2024 (08:15)
    
    # Find the year in the first timestamp
    for (i=1; i<=NF; i++) {
      if ($i ~ /^20[0-9][0-9]$/) {
        year_pos = i
        break
      }
    }
    
    if (year_pos) {
      # Extract start time and end time based on detected positions
      start_date = $(year_pos-3) " " $(year_pos-2) " " $(year_pos-1) " " $year_pos
      
      # Find the dash separator position
      for (i=1; i<=NF; i++) {
        if ($i == "-") {
          dash_pos = i
          break
        }
      }
      
      if (dash_pos) {
        # End date follows the dash
        end_date = $(dash_pos+1) " " $(dash_pos+2) " " $(dash_pos+3) " " $(dash_pos+4)
        
        # Duration is typically the last field in parentheses
        duration = $NF
        gsub(/[()]/, "", duration)  # Remove parentheses
        
        # Extract hours and minutes from duration (format: HH:MM)
        split(duration, time_parts, ":")
        hours = time_parts[1]
        minutes = time_parts[2]
        
        # Convert to decimal hours
        decimal_hours = hours + (minutes / 60)
        
        # Print the session details
        printf "%-25s → %-25s  (%.2f h)\n", start_date, end_date, decimal_hours
        total_hours += decimal_hours
      }
    }
  }
  END {
    print "-----------------------------------------------------------"
    printf "Total interactive login time since 2024-01-01: %.2f hours\n", total_hours
  }
' my_sessions.txt

# Clean up temporary file
# rm my_sessions.txt