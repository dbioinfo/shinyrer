library(tidyverse)
library(ape)
library(readxl)

#set wd
setwd('Postdoc/Hindle/ana/')

#####################
#     Import Data   #
#####################

#Load phylogeny
mtree <- read.tree("raw_data/upham_tree/pbio.3000494.s023/S3_Data/Data_S3_globalRAxML_files/RAxML_bipartitions.result_FIN4_raw_rooted_wBoots_4098mam1out_OK.newick")

#species labels contain some weird family names
species <- mtree$tip.label
tree_species <- tibble(spec=species) %>% 
  separate(spec, into=c('Genus','Species','Fam1','Fam2'), sep = '_') %>% 
  mutate(species = tolower(paste(Genus,Species,sep='_'))) %>%
  select(species)
mtree$tip.label <- tree_species$species
#row 4099 is _Anolis, the lizard root of the tree

#Load phenotype data from excel
phenotypes <- read_excel("raw_data/phenotype/All Tb Data (Zoonomia species only).xlsx", sheet = 5, col_names = T)
colnames(phenotypes)[24] <- 'Tb' #rename column for ease of access
colnames(phenotypes)[2] <- 'species' #rename column for ease of access


#first, before iterating, check agreement between species in tree and phenotypes
#final_specs <- intersect(tree_species$species, phenotypes$species) #341 / 411 defined in phenotypes
#missing_specs <- setdiff(phenotypes$species, tree_species$species) #70 species in phenotypes not in tree
#write.csv(missing_specs, '~/Downloads/missing_species.csv')
#write.csv(tree_species$species, '~/Downloads/tree_species.csv')

#Load alignment species
align_translate <- read_delim('raw_data/cactus_aligns/overview.table.tsv', delim='\t')
colnames(align_translate)[5] <- 'assembly'
toga_species <- align_translate %>% mutate(species = tolower(gsub(' ', '_', Species))) %>% select(species, assembly) %>% add_row(species='homo_sapiens', assembly='GRCh38')

##################################
#    Gen minimal master tree     #
##################################

#check agreement between species in tree, phenotype and toga
final_specs <- intersect(intersect(tree_species$species, phenotypes$species), toga_species$species) #339 / 411 defined in phenotypes
ptree <- drop.tip(mtree, setdiff(mtree$tip.label, final_specs)) #prune tree to only include minimal set
write.tree(ptree, 'data/pruned_master_tree.newick')


##################################
#  Gen species lists each gene   #
##################################

#function to import fasta files -- then translate the genome assembly names to species naems
import_species <- function(path){
  lfile <- read.FASTA(path) #import alignment
  #specs <- names(lfile) #only work with the colnames
  #assemblies <- tibble(species=specs) %>% separate(species, into=c('trash1', 'genome', 'trash2'), sep = '\t|_') %>% pull(genome) #format to only include genome assembly 
  assemblies <- names(lfile)
  species <- toga_species %>% filter(assembly %in% assemblies) %>% pull(species) 
  return(species)
}
fnames <- list.files('data/alignments', pattern='fasta', full.names=T) #needed to reformat these with python, now in data/alignments
#record the species present in each alignment
genewise_species <- tibble(Gene=NA, Species=NA)
for (fname in fnames){
  gene <- strsplit(fname, '\\.')[[1]][2] #extract gene name
  aligned_species <- import_species(fname) #import species from alignment
  genewise_species <- genewise_species %>% add_row(tibble_row(Gene=gene, Species= paste(aligned_species,collapse=';') )) #record species present in alignment
  #progress check
  if (fname==fnames[5000]){print('5000/~17000 Genes Complete')} else if (fname==fnames[10000]){print('10000/~17000 Genes Complete')} else if (fname==fnames[15000]){print('15000/~17000 Genes Complete')}
  
}

genewise_species <- na.omit(genewise_species)
write.csv(genewise_species, 'data/alignment_genewise_species.csv', row.names=F)


#alignments have weird names for each species, they are prefixed with vs_ and the name of the genome
#this causes a problem when matching the tips of the trees, so we need to adjust the tree with genome names 
#which is easier than adjusting the alignment names, use the toga_species table to translate but
#many assemblies for each species, so try to extract the latest genome assembly 
#( I hope I don't have to dynamically search for these in the case that old assemblies are represented in these alignments )
#so much needs to change, I'm going to reformat all the cactus data. What tf is this naming scheme anyway.
translate <- toga_species %>% 
  group_by(species) %>% 
  summarise(latest_assembly = last(assembly)) %>% 
  left_join(toga_species, by='species') %>% 
  select(species, latest_assembly) %>% 
  unique() %>% 
  filter(species %in% mtree$tip.label) %>% 
  arrange(factor(species, levels=mtree$tip.label))
#write_csv(translate, 'data/alignment_species_translation.csv')

new_tree <- mtree
new_tree$tip.label <- translate$latest_assembly
write.tree(new_tree, 'data/pruned_renamed_master_tree.newick')
