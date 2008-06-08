convert_header()
{
mv $1 orig

sed  -e "s/include.*fin\.ch/include \"fin.ch/" orig > $1

}

FILES=`ls *.prg`

for f in $FILES ; do
  convert_header $f
done
