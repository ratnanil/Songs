for d in */*.qmd; do 
    # sed $'s/\u0020/\./g' $d
    perl -i -p -e "s/\x{0020}\x{0020}/\x{0020}\x{00a0}/g;" $d 
done