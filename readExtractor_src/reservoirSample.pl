#!/usr/bin/perl -sw
#http://data-analytics-tools.blogspot.com/2009/09/reservoir-sampling-algorithm-in-perl.html
 
$IN = 'STDIN' if (@ARGV == 1);
open($IN, '<'.$ARGV[1]) if (@ARGV == 2);
die "Usage:  perl samplen.pl <lines> <?file>\n" if (!defined($IN));
 
$N = $ARGV[0];
@sample = ();
 
while (<$IN>) {
    if ($. <= $N) {
 $sample[$.-1] = $_;
    } elsif (($. > $N) && (rand() < $N/$.)) {
 $replace = int(rand(@sample));
 $sample[$replace] = $_;
    }
}
 
print foreach (@sample);
close($IN);
