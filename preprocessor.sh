echo preprocessing

# for all qmd files in subdirectories...
for d in */*.qmd; do 
    # ...determine the line number of the YAML terminator (second "---")
    line=$(grep -n "^---" $d | head -2 | tail -1 | awk -F: '{print $1}' )
    echo $d $line
    # ...replace various form of double spaces wtih non-breaking spaces. BUT: skip the YAML header. 
    perl -i -sne 'if ($. < $n) { print } else { s/  /  /g; print }' -- -n=$line $d  # double spaces
    perl -i -sne 'if ($. < $n) { print } else { s/  /  /g; print }' -- -n=$line $d  # space + non-breaking space
    perl -i -sne 'if ($. < $n) { print } else { s/  /  /g; print }' -- -n=$line $d  # non-breaking space + space
    perl -i -sne 'if ($. < $n) { print } else { s/^ / /g; print }' -- -n=$line $d   # space at beginning of line
    # -i is in-place edit
    # -s is to pass arguments to the script ($n in this case, which is assigned after the --)
    # -n is the line number of the YAML terminator
    # -e is to pass a script to the perl interpreter
done

