
merge.sum<-function(parentdir=".", curdir){

 summarytable <- NULL

 chroms<-c(1:22, "X", "Y")

 for(i in 1:length(chroms)){

   #filename<-paste(parentdir, "/", curdir, "/", "chr", chroms[i], ".sum", sep="")
    filename<-paste(parentdir, "/", curdir, "/", "chr", chroms[i], ".sum", sep="")

   if(file.exists(filename)){

      sum<-read.table(file=filename , header = TRUE, sep = " ", as.is = TRUE, na.strings = "NA")

        if(i==1){
   	summarytable<-sum

       }
       else{
          summarytable<-rbind(summarytable, sum)
    }

   }



   }




   ###
   ###  ?????? Col names
   ###
   #  colnames(summarytable)<-c("seg.start", "seg.end", "state", "length", "copyEst", "seg.median", "zstat", "chrom", "chrom.pos.start", "chrom.pos.end")
   ###

   summarytable<-data.frame(summarytable$chrom, summarytable$chrom.pos.start, summarytable$chrom.pos.end, summarytable$copyEst, round(summarytable$zstat,digit=4))

   colnames(summarytable) <- c("chr","start","end","copy","zstat")

   write.table(summarytable, file = paste(parentdir, "/", curdir, "/", paste(curdir, "summary.txt", sep="") , sep=""), append = FALSE, quote = FALSE, sep = "\t",
               eol = "\n", na = "NA", dec = ".", row.names = FALSE,
               col.names = TRUE, qmethod = c("escape", "double"))


}
