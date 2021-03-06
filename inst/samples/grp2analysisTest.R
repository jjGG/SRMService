rm(list=ls())

dir("inst/samples/")
protein <- read.table(("inst/samples/proteinGroups/proteinGroups2x4.txt"),sep="\t",stringsAsFactors = F, header=T)

rawF <- gsub("Intensity\\.", "", grep("Intensity\\.",colnames(protein),value=T) )


condition <- quantable::split2table(rawF)[,3]
annotation <-data.frame(Raw.file = rawF,
                        Condition = condition,
                        BioReplicate = paste("X",1:length(condition),sep=""),
                        Run = 1:length(condition),
                        IsotopeLabelType = rep("L",length(condition)), stringsAsFactors = F)


tmp <- cumsum(rev(table(protein$Peptides)))
barplot(tmp[(length(tmp)-5):length(tmp)],ylim=c(0, length(protein$Peptides)),xlab='nr of proteins with at least # peptides')

head(protein$Peptides)
library(SRMService)

grp2 <- Grp2Analysis(annotation, "p2084BlaBla", maxNA=8  , nrPeptides=2)
grp2$setMQProteinGroups(protein)
head(protein)

