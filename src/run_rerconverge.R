##################################
#   Gen RER trees and weights    #
##################################
library(RERconverge)
library(tidyverse)
library(readxl)

########################
#  Import and Prepare  #
########################

#set file locations
setwd('Postdoc/Hindle/ana/')
treefile="data/gene_trees/eif4g.trees"
pfile='raw_data/phenotype/Tb_data.xlsx'
transfile="data/alignment_species_translation.csv"

#import
trees=readTrees(treefile)
phenos=read_xlsx(pfile, sheet=5)[c(2,24)]
colnames(phenos) <- c('species','Tb')
trans <- read_csv(transfile)

#prepare
phenos <- merge(phenos, trans, by='species') %>% 
  mutate(Tb = as.numeric(Tb, na.rm=T)) %>% 
  filter(!is.na(Tb))
corDat <- phenos$Tb
names(corDat) <- phenos$latest_assembly


########################
#  Run analysis, save  #
########################

#initial RER calculation
res <- getAllResiduals(trees,useSpecies=names(corDat),
                transform = "sqrt", weighted = T, scale = T)

saveRDS(res, file='data/rer.RDS')
#res <- readRDS('data/rer.RDS')

#correlation with phenotype
charpaths<-char2Paths(corDat, trees)
cors <- correlateWithContinuousPhenotype(res, charpaths, min.sp = 10,
                                     winsorizeRER = 3, winsorizetrait = 3)
saveRDS(cors, file='data/rercors.RDS')
