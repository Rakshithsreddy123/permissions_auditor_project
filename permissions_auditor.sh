#!/bin/bash
#Permission Auditor Script

TARGET_DIR="${1:-.}" #the directory specified in the arguement or the current working directory(.)
REPORT_FILE="permissions_audit_report.txt"
INSECURE_PERM_CODE="/002" #files with world-writable permissions
INSECURE_FILES=0
INCORRECT_FILES=0

#function to check if the file has world-writable permissions( other category has w)
check_world_writable() {

        find -L "$1" -mount \( -type f -o -type d \) -perm "$INSECURE_PERM_CODE" 2>/dev/null \
                -printf "PERM: %m | OWNER: %u | GROUP: %g | PATH: %p | FILE: %f\n"

}

#function to check if the file has incorrect user(other than the root user)
check_incorrect_ownership() {

        find -L "$1" -mount ! -user root 2>/dev/null \
                -printf "PERM: %m | OWNER: %u | GROUP: %g | PATH:%p | FILE: %f\n"

}

#Main Script
echo "Permissions Audit Script Started at $(date)" > "$REPORT_FILE"
echo "Target Directory: $TARGET_DIR" >> "$REPORT_FILE"
echo "--------------------------------------------------------------" >> "$REPORT_FILE"


REPORT_1=$(check_world_writable "$TARGET_DIR")
REPORT_2=$(check_incorrect_ownership "$TARGET_DIR")

INSECURE_FILES=$(echo -n "$REPORT_1" | wc -l)
INCORRECT_FILES=$(echo -n "$REPORT_2" | wc -l)

{
        echo -e "---Checking for world-writable files/directories in $1 (o+w) ---"
    	echo "$REPORT_1"
	echo "Total files with Incorrect Permissions(world-writable) are: $INSECURE_FILES"

        echo -e "\n ---Checking for Files/Directories NOT owned by the 'root' in $1 ---"
   	echo "$REPORT_2"
    	echo "Total files with Incorrect Ownership (! root) are: $INCORRECT_FILES"

} >> "$REPORT_FILE"

echo "--------------------------------------------------------------------------" >> "$REPORT_FILE"
echo "Permissions Auditor Script Finished." >> "$REPORT_FILE"
echo "Report generated to : $REPORT_FILE"

TOTAL_INSECURE=$((INSECURE_FILES + INCORRECT_FILES))

if [ "$TOTAL_INSECURE" -eq 0 ];
then
        echo " Audit complete. No insecure entreis found based on the current criteria."
else
        echo " Security Alert: $TOTAL_INSECURE insecure entries found!! Check $REPORT_FILE for more details..."
fi

