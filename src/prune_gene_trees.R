library(tidyverse)
library(ape)
library(RERconverge)

#import
allgenes <- read_tsv('data/gene_trees/all_genes.trees', col_names = c('gene','tree'))
phenos <- read_csv('data/phenotype_vec.csv', col_names = c('species','pheno'))

#create parallelization of pruning
out <<- data.frame(matrix(nrow=0, ncol=2))
colnames(out) <- c('gene','tree')
fix_tree <- function(gene, tree) {
  gene <- gsub('.fasta','',gene)
  tree <- read.tree(text=tree) 
  tree <- drop.tip(tree, setdiff(tree$tip.label, phenos$species))
  fname <- paste0('data/pruned_trees/', gene, '_pruned.nwk')
  write.tree(tree, file=fname)
  txt <- read_tsv(fname, col_names = c('tree'))$tree
  row <- data.frame(gene=gene, tree=txt)
  out <<- rbind(out, row)
}

#apply
mapply(fix_tree, allgenes$gene, allgenes$tree)

write_tsv(out, 'data/gene_trees/all_genes_pruned.trees')
