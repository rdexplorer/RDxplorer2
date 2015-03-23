# RDxplorer2

what does the program do?

**part1:  Event Finding**

descrip1

**part2:  Paired Read Extraction**

descrip2

**part3:  Event Validation**

descrip3


Installation
-------------

RDxplorer2 relies on features available to specific versions of the following software:

* samtools version: 0.1.19 or higher
http://sourceforge.net/projects/samtools/files/samtools/0.1.19/

* perl v5.8.8 or higher

* R version 2.15.2 or higher

Once the prerequisite software is up to date, installation is simple.

Just unzip the archive:

```bash
	tar -zxvf rdexplorer-RDxplorer2.tar.gz 
```
And add the root project directory to your path:

```bash
	export PATH=$(pwd)/rdexplorer-RDxplorer2:$PATH
```

    
Usage
-----
how to run each part separately.


**part1:  Event Finding**

descrip1

**part2:  Paired Read Extraction**

There are four input arguments for this script: 

1. a sorted and indexed .bam file( with the .bai located the same directory)
2. either 
  * a summary file containing at least 4 columns for state, chrom, startPos, endPos.
  * a folder containing the *.sum output from the first part of the program
3. a quality score threshold for paired reads
4. a max quality score threshold for sampling the insert template length distribution

```bash
runReadExtractor.sh input.bam summary.txt 32 60
```

The output is a new folder named "pairedReads" created in the current directory.  
Inside are "delEvents.txt" and "dupEvents.txt" with the following tab delimited columns:
* 1  : a unique identifier for the event
* 2-4: the 4 columns of interest
* 5- : the original summary info.

the 24 paired reads files, "dels_*.pr", and "dups_*.pr", split by chromosome.
Each .pr has the reads' info along with a column showing the event they belong to. 

The insert template length distribution file, "insDistr.txt".  this is a sampling of the
template lengths from ~50k high quality read pairs.

**part3:  Event Validation**

Make sure you're in the same directory that you were in when you ran the previous step.
Then run:
```bash
  runEventValidator.sh
```
It will write the event calls into the pairedReads folder.


Contributors
---------


License
---------

