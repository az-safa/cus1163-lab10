#!/bin/bash

# Define the test directory path
TEST_DIR="$HOME/cus1163-lab10/test_files"

# ==========================================
# SETUP TEST ENVIRONMENT
# ==========================================
setup_test_environment() {
    echo "Setting up test environment..."
    
    # Clean up old directory if it exists and recreate it
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"/{web,config,scripts,data,uploads}

    # Web files
    touch "$TEST_DIR/web/index.html" && chmod 777 "$TEST_DIR/web/index.html"
    touch "$TEST_DIR/web/style.css" && chmod 755 "$TEST_DIR/web/style.css"
    touch "$TEST_DIR/web/script.js" && chmod 644 "$TEST_DIR/web/script.js"

    # Config files
    touch "$TEST_DIR/config/database.conf" && chmod 666 "$TEST_DIR/config/database.conf"
    touch "$TEST_DIR/config/api_keys.conf" && chmod 644 "$TEST_DIR/config/api_keys.conf"
    touch "$TEST_DIR/config/settings.conf" && chmod 755 "$TEST_DIR/config/settings.conf"

    # Script files
    touch "$TEST_DIR/scripts/deploy.sh" && chmod 755 "$TEST_DIR/scripts/deploy.sh"
    touch "$TEST_DIR/scripts/backup.sh" && chmod 777 "$TEST_DIR/scripts/backup.sh"

    # Data files
    touch "$TEST_DIR/data/users.txt" && chmod 666 "$TEST_DIR/data/users.txt"
    touch "$TEST_DIR/data/logs.txt" && chmod 640 "$TEST_DIR/data/logs.txt"

    # Uploads dir (World-writable directory)
    chmod 777 "$TEST_DIR/uploads"

    echo "Test files created in: $TEST_DIR"
    echo ""
}

# ==========================================
# TODO 1: Find World-Writable Items
# ==========================================
find_world_writable() {
    local count=0
    
    # Use process substitution to preserve the count variable
    while IFS= read -r item; do
        # Get the numeric permissions of the item
        perms=$(stat -c "%a" "$item")
        
        # Check if the item is a file or directory and format output
        if [ -f "$item" ]; then
            echo "[FILE] $item ($perms)"
        elif [ -d "$item" ]; then
            echo "[DIR]  $item ($perms)"
        fi
        
        # Increment the counter
        ((count++))
    done < <(find "$TEST_DIR" -perm -002)

    echo ""
    echo "Found $count world-writable items"
    
    # Return the count to the main function
    return $count
}

# ==========================================
# TODO 2: Find Executable Non-Scripts
# ==========================================
find_executable_non_scripts() {
    local count=0
    
    # Find files matching specific extensions that have any execute bit set
    while IFS= read -r file; do
        perms=$(stat -c "%a" "$file")
        echo "[EXEC] $file ($perms)"
        
        ((count++))
    done < <(find "$TEST_DIR" -type f \( -name "*.html" -o -name "*.css" -o -name "*.txt" -o -name "*.conf" \) -perm /111)

    echo ""
    echo "Found $count files that shouldn't be executable"
    
    return $count
}

# ==========================================
# MAIN EXECUTION
# ==========================================
main() {
    echo "========================================"
    echo "File Permission Security Scanner"
    echo "========================================"
    
    # 1. Setup the files
    setup_test_environment
    
    echo "========================================"
    echo "Scanning for INSECURE Files/Directories"
    echo "========================================"
    echo ""
    
    # 2. Run TODO 1
    echo "--- World-Writable Files & Directories ---"
    echo ""
    find_world_writable
    local ww_count=$?
    
    echo ""
    
    # 3. Run TODO 2
    echo "--- Executable Non-Script Files ---"
    echo ""
    find_executable_non_scripts
    local exec_count=$?
    
    # 4. Print Summary
    echo "========================================"
    echo "Security Scan Complete"
    echo "========================================"
    echo "Summary:"
    echo "- World-writable items found: $ww_count"
    echo "- Improperly executable files found: $exec_count"
    
    local total=$((ww_count + exec_count))
    echo "- Total security issues: $total"
    
    if [ "$total" -gt 0 ]; then
        echo "⚠️  SECURITY ALERT: $total permission vulnerabilities detected!"
        echo "These files need immediate attention."
    fi
    echo "========================================"
}

# Kick off the script
main
