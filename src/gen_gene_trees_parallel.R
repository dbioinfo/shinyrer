##################################
#  Gen gene-wise species trees   #
##################################
library(RERconverge)

#prep phanghorn (important not to have trailing /)

mastertreefn='data/pruned_renamed_master_tree.newick'
alignmentfn='data/alignments'
outputfn="data/gene_trees/all_trees.trees"

#run it (30 sec - 1 min per gene .. might be worth parallel batching gonna run overnight and see what kind of progress it can make, -- still on As)
#need to split into many jobs, use a pattern match as input to parallelize
gene_by_alpha <- function(ipattern) {
  estimatePhangornTreeAll(alndir=alignmentfn, treefile=mastertreefn, output.file=outputfn, format='fasta', type='DNA', submodel = 'GTR', pattern = ipattern)
}

#gen list of patterns, each one should be regex for 'starts with this letter [a-z]'
patterns=paste('^', LETTERS, sep='')

#parallelize the bitch
mclapply(patterns, gene_by_alpha)

