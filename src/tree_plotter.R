library(tidyverse)
library(ggtree)
library(treeio)

setwd('Postdoc/Hindle/ana')
translate <- read.csv('data/alignment_species_translation.csv')

species <- read.tree(file='data/pruned_renamed_master_tree.newick')
eg1 <- read.tree(file='data/gene_trees/EIF4G1.newick')
eg3 <- read.tree(file='data/gene_trees/EIF4G3.newick')

species <- rename_taxa(species, translate, latest_assembly, species)
eg1 <- rename_taxa(eg1, translate, latest_assembly, species)
eg3 <- rename_taxa(eg3, translate, latest_assembly, species)

focus_species <- c(sample(translate$species, 30) , c('sorex_araneus','homo_sapiens','procavia_capensis','mus_musculus'))

g1 <- ggtree(eg1, layout = 'circular', color='#f2dabd') + 
  geom_tiplab2(aes(subset=(grepl(paste(focus_species, collapse='|'),label))), color='#f2dabd', size=2) +
  theme(
    panel.background = element_rect(fill = "transparent",colour = NA), # or theme_blank()
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_blank(),
    plot.background = element_rect(fill = "transparent",colour = NA)
  )

g3 <- ggtree(eg3, layout = 'circular', color='#f2dabd') + 
  geom_tiplab2(aes(subset=(grepl(paste(focus_species, collapse='|'),label))), color='#f2dabd', size=2)+
  theme(
    panel.background = element_rect(fill = "transparent",colour = NA), # or theme_blank()
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_blank(),
    plot.background = element_rect(fill = "transparent",colour = NA)
  )


spec <- ggtree(species, layout='circular', color='#f2dabd') + 
  geom_tiplab2(aes(subset=(grepl(paste(focus_species, collapse='|'),label))), color='#f2dabd', size=2) +
  theme(
    panel.background = element_rect(fill = "transparent",colour = NA), # or theme_blank()
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_blank(),
    plot.background = element_rect(fill = "transparent",colour = NA)
  )


ggsave('figs/species_tree.png', spec, bg='transparent')
ggsave('figs/eif4g1_tree.png', g1, bg='transparent')
ggsave('figs/eif4g3_tree.png', g3, bg='transparent')
