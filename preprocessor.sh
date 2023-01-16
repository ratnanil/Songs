echo preprocessing
for d in */*.qmd; do 
    # sed $'s/\u0020/\./g' $d
    perl -i -p -e "s/  /  /g;" $d #searching for \u0020\u0020 and replacing with \u00a0\u00a0
    perl -i -p -e "s/  /  /g;" $d #searching for \u0020\u00a0 and replacing with \u00a0\u00a0
    perl -i -p -e "s/  /  /g;" $d #searching for \u00a0\u0020 and replacing with \u00a0\u00a0
    perl -i -p -e "s/^ / /g;" $d  #searching for u0020 at the beginning of a line and replacing it with \u00a0

done