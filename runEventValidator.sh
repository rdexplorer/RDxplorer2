

codepath=$(readlink -f "$(dirname $BASH_SOURCE)")

cd pairedReads
echo "code:  $codepath/dup_support_new.R"
echo "code:  $codepath/del_support_new.R"
Rscript $codepath/dup_support_new.R
Rscript $codepath/del_support_new.R
cd ..
