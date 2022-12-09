rm */*.md
for d in */*.qmd; 
    do sed $'s/\u0020\u0020/\u0020\u00a0/g' $d > ${d%%.*}.md;
done
quarto render 
rm */*.md
# perl -i.bak -p -e 's/\x{0020}\x{0020}/\x{0020}\x{00a0}/g' *.qmd
# perl -i.bak -p -e "Encode::from_to($_, 'Windows-1255', 'utf-8')" index.qmd
# quarto render
#for file in *.qmd.bak; do cp "$file" "${file//.bak}"; done
# rm *.qmd
# rename "s/\.bak//" *.bak -v -d 