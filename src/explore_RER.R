library(tidyverse)
library(RERconverge)
library(plotly)

RERw <- readRDS('data/RERw.rds')
trees <- readRDS('data/trees.rds')
cor <- readRDS('data/cor.rds')
translate <- read_csv('data/alignment_species_translation.csv')

pheno <- read.csv('data/phenotype_vec.csv')
colnames(pheno) <- c('latest_assembly','temp')
phvals <- t(pheno$temp)
names(phvals) <- pheno$latest_assembly
charpaths=char2Paths(phvals, trees)

igene <- 'RAP1A'

#####
# single-gene RER corr


#prepare for graph
x <- charpaths
y <- RERw[igene,]
pathnames<-namePathsWSpecies(trees$masterTree)
temp <- tibble(latest_assembly=pathnames, x=x, y=y)
temp <- left_join(temp, translate, by='latest_assembly')

#line of best fit
fv <- temp %>% filter(!is.na(y)) %>% filter(!is.na(species)) %>% lm(y ~ x,.) %>% fitted.values()

#produce graph
temp %>% filter(!is.na(y)) %>% filter(!is.na(species)) %>% 
  plot_ly(x=~x) %>% 
  add_markers(y=~y, text=~species, hoverinfo = 'text') %>% 
  add_trace(x=~x, y=fv, mode='lines') %>% 
  layout(title=igene, xaxis=list(title='Normalized Body Temp'), yaxis=list(title='Relative Evolutionary Rate') )

#####
# single-gene RER

#prepare data for graph
subg <- which(!is.na(names(RERw[igene,which(!is.na(RERw[igene,]))])))
subset <- RERw[igene,which(!is.na(RERw[igene,]))][subg]
subset <- tibble(latest_assembly=names(subset), RER=subset) %>% mutate(idx=1:length(subset))
subset <- left_join(subset, translate, by='latest_assembly')

#assign color labels to top/bottom 10%
top <- quantile(subset$RER, probs=0.9)
bottom<- quantile(subset$RER, probs=0.1)
subset <- subset %>%  mutate(sig = case_when(
        RER>top ~ 'high',
        RER<bottom ~ 'low',
        TRUE ~ 'mid'
          ))

subset %>% 
  plot_ly(x=~RER, y=~idx) %>% 
  add_markers(x=~RER, y=~idx, color=~sig, text=~species, hoverinfo='text') %>% 
  layout(title=paste0(igene,' Relative Evolutionary Rate'), yaxis=list(title='Branches'))



#####
# Tree

#prepare trees with correct tip labels


ttemp <- trees$trees[[igene]]
atemp <- trees$masterTree
tmeta <- tibble(latest_assembly = ttemp$tip.label) %>% 
  left_join(translate, by='latest_assembly') %>% 
  left_join(pheno, by='latest_assembly')
ameta <- tibble(latest_assembly = atemp$tip.label) %>% 
  left_join(translate, by='latest_assembly') %>% 
  left_join(pheno, by='latest_assembly')

tavg <- ggtree(atemp)
meta_avg <- tavg$data %>%
  dplyr::inner_join(ameta, c('label' = 'latest_assembly'))
tavg <- tavg +
  geom_point(data = meta_avg,
             aes(x = x,
                 y = y,
                 label = species))

tgene <- ggtree(ttemp)
meta_gene <- tgene$data %>%
  dplyr::inner_join(tmeta, c('label' = 'latest_assembly'))
tgene <- tgene +
  geom_point(data = meta_gene,
             aes(x = x,
                 y = y,
                 species = species, 
                 Tb = temp))

t1 <-plotly::ggplotly(tavg, tooltip=c('species','Tb')) 
t2 <-plotly::ggplotly(tgene, tooltip=c('species','Tb'))  

subplot(t1, t2) %>% 
  layout(annotations = list(
  list(x = 0.15 , y = 1.05, text = "Average Gene Tree", showarrow = F, xref='paper', yref='paper'),
  list(x = 0.8 , y = 1.05, text = paste0(igene," Gene Tree"), showarrow = F, xref='paper', yref='paper'))
)

#hlspecies=c("octodon_degus","tamandua_tetradactyla")