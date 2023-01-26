echo preprocessing
for d in */*.qmd; do 
    # determin the line number of the YAML terminator (second ---)
    line=$(grep -n "^---" $d | head -2 | tail -1 | awk -F: '{print $1}' )
    echo $d $line
    # replace various form of double spaces wtih non-breaking spaces. BUT: skip the YAML header. 
    perl -i -sne 'if ($. < $n) { print } else { s/  /  /g; print }' -- -n=$line $d
    perl -i -sne 'if ($. < $n) { print } else { s/  /  /g; print }' -- -n=$line $d
    perl -i -sne 'if ($. < $n) { print } else { s/  /  /g; print }' -- -n=$line $d
    perl -i -sne 'if ($. < $n) { print } else { s/^ / /g; print }' -- -n=$line $d
done