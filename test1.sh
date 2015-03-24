
#run all three parts together
perl Rdxplorer2.pl -All In=/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/LP6005162-DNA_A01.bam Out=/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results.rdxp



perl Rdxplorer2.pl -Depth In=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/LP6005162-DNA_A01_chr22.bam Out=/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results.rdxp qualThresh=37 maxQualThresh=60
perl Rdxplorer2.pl -PairCollect In=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/LP6005162-DNA_A01_chr22.bam Out=/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results.rdxp qualThresh=37 maxQualThresh=60
perl Rdxplorer2.pl -PairValid In=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/LP6005162-DNA_A01_chr22.bam Out=/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results.rdxp qualThresh=37 maxQualThresh=60
perl Rdxplorer2.pl -All In=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/LP6005162-DNA_A01_chr22.bam Out=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results qualThresh=37 maxQualThresh=60
perl Rdxplorer2.pl -All In=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/LP6005162-DNA_A01_chr22.bam Out=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results qualThresh=200 maxQualThresh=254


#log into wigclust1
export PATH=$PATH:/data/software/samtools/samtools-0.1.19
time perl Rdxplorer2.pl -All In=testbams/A01.bwa.small.bam Out=testbams/results qualThresh=37 maxQualThresh=60
time perl Rdxplorer2.pl -PairCollect In=/data/unsafe/autism/NYGC_WG/sample/SSC05996/sample.bam Out=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/SSC05996/results qualThresh=37 maxQualThresh=60
time perl Rdxplorer2.pl -PairValid In=/data/unsafe/autism/NYGC_WG/sample/SSC05996/sample.bam Out=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/SSC05996/results qualThresh=37 maxQualThresh=60


perl Rdxplorer2.pl -Depth In=/mnt/wigclust8/data/safe/kpradhan/projects/kenny/rdexplorer/data1/A01.bwa.small.bam Out=/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results.rdxp qualThresh=37 maxQualThresh=60
perl Rdxplorer2.pl -PairCollect In=/mnt/wigclust8/data/safe/kpradhan/projects/kenny/rdexplorer/data1/A01.bwa.small.bam Out=/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results.rdxp qualThresh=37 maxQualThresh=60
perl Rdxplorer2.pl -PairValid In=/mnt/wigclust8/data/safe/kpradhan/projects/kenny/rdexplorer/data1/A01.bwa.small.bam Out=/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results.rdxp qualThresh=37 maxQualThresh=60



perl Rdxplorer2.pl -PairCollect In=/mnt/wigclust8/data/safe/kpradhan/projects/kenny/rdexplorer/data1/A01.bwa.small.bam Out=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/output_originalVersion/results.rdxp qualThresh=37 maxQualThresh=60


samtools view -s 0.0001 -hb /data/unsafe/autism/NYGC_WG/sample/SSC05996/sample.bam test1.bam


###################################
#testing on the small bam files
#need to use full path name, no relative paths

#the full pipeline on chr22 and Y bamfile
#takes about 30 min
perl Rdxplorer2.pl -All In=/home/kpradhan/data/projects/kenny/rdexplorer/program_file_RDxplorer2/testbams/bam2/sorted.small_21Y.bam Out=/home/kpradhan/data/projects/kenny/rdexplorer/program_file_RDxplorer2/testbams/bam2/results qualThresh=37 maxQualThresh=60


#takes about 10 min
#just the read collecting part
#the output files needs to have a "/results1" part after the output filename 
time perl Rdxplorer2.pl -PairCollect In=/home/kpradhan/data/projects/kenny/rdexplorer/program_file_RDxplorer2/testbams/bam1/A01.bwa.small.bam Out=/home/kpradhan/data/projects/kenny/rdexplorer/program_file_RDxplorer2/testbams/bam1/results/results1 qualThresh=37 maxQualThresh=60


