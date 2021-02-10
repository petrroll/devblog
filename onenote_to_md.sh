# Replace tabs with two spaces '  '
# Remove one indentation level from all notes
# Replace list marks with `-`

sed -E '
s/\t/  /g
s/^  //g
s/^([ ]*)[•○§]/\1-/g' -i $1