codepath="$(dirname $BASH_SOURCE)"

cd pairedReads
Rscript $codepath/dup_support_new.R
Rscript $codepath/del_support_new.R
cd ..
