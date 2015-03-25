# RDxplorer2

todo:  goal of prog?

**Event Finding:**
Finds the region boundaries of possible copy number events.

**Paired Read Extraction:**
Finds the read pairs that have at least one mate 
close to the events found in the previous step.  

**Event Validation:**
Assigns probabilities to events based on their read pair info.


Installation
-------------

RDxplorer2 relies on specific versions of the following software:

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

Alternatively, you can specify the full path to the 
program scripts when running from the command line.
    

Usage
-----
This version of the software allows you to run each part separately.


**Event Finding**

This perl script takes the location of the bam file as its single command line argument.
The file is assumed to be sorted by position and indexed, with its .bai 
located in the same directory as the .bam.

To run the script:
```bash
runEventFinder.pl input.bam
```

It outputs one summary file(rdxp.chr\*\.rdx_raw.sum) for each chromosome where events are found.


**Paired Read Extraction**

There are four input arguments for this script: 

1. a sorted and indexed .bam file(with the .bai located the same directory)
2. one of the following 
  * a summary file containing at least 4 columns for state, chrom, startPos, endPos, 
  with events sorted in chromosomal order.
  * a folder containing the *.sum output files from the first part of the program
3. a quality score threshold for paired reads.  Reads lower than the threshold this will be ignored.
4. a quality score threshold for sampling the insert template length distribution.  
Reads lower than the threshold will be ignored

To run the script:
* If you have a list of precomputed events:
```bash
runReadExtractor.sh input.bam summary.txt 32 60
```

* If you have a preexisting folder containing the .sum files generated from **event finding**:
```bash
runReadExtractor.sh input.bam resultFolder 32 60
```

* If you have just run **event finding** and are still in the same directory:
```bash
runReadExtractor.sh input.bam . 32 60
```

The output will be a newly created folder called "pairedReads" placed in the current directory.  

Inside are "delEvents.txt" and "dupEvents.txt" with tab delimited columns:
* cols 1  : a unique identifier for the event
* cols 2-4: the 4 columns of interest.
* cols 5- : the original summary info.

There are 24 paired reads files, "dels\_\*.pr", and "dups\_\*.pr", split by chromosome.
Each .pr has the reads' mapping info along with a column showing the event they are from. 

There is an insert template length distribution file, "insDistr.txt".  
This is a sampling of ~50k template lengths from high quality read pairs.


**Event Validation**

The program assumes there is a properly constructed "pairedReads" folder in the current directory.
If you have run the previous command, the folder will be loaded with all the necessary files.

To run the script:
```bash
  runEventValidator.sh
```
It will write the event calls into the pairedReads folder.

todo:  add description of del/dup call files.

Contributors
---------
* Kenny Ye <kyeblue@gmail.com>
* Chris Yoon <mgflute@gmail.com>
* Kith Pradhan <kpradhan@cshl.edu>


License
---------

