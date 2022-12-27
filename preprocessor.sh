echo preprocessing
for d in */*.qmd; do 
    # sed $'s/\u0020/\./g' $d
    perl -i -p -e "s/  /  /g;" $d #searching for \u0020\u0020 and replacing with \u0020\u00a0
done