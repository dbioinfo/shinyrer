server <- shinyServer(function(input, output, session) {
  #declare global / reactive vars
  react_var1 <- reactiveVal()
  corrr <- reactiveVal()
  trees <- reactiveVal()
  RERw <- reactiveVal()
  genes <- reactiveVal()
  translate <- reactiveVal()
  pheno <- reactiveVal()
  phvals <- reactiveVal()
  charpaths <- reactiveVal()
  igene <- reactiveVal()

  
  observeEvent(input$run,{ #script to init server
    #usually where you'd load a csv or connect to a database
    RERw <<- readRDS('/home/dylan/Postdoc/Hindle/ana/data/RERw.rds')
    trees <<- readRDS('/home/dylan/Postdoc/Hindle/ana/data/trees.rds')
    corrr <<- readRDS('/home/dylan/Postdoc/Hindle/ana/data/cor.rds')
    translate <<- read_csv('/home/dylan/Postdoc/Hindle/ana/data/alignment_species_translation.csv')
    
    #process some initial data to format everything right
    pheno <<- read.csv('/home/dylan/Postdoc/Hindle/ana/data/phenotype_vec.csv')
    colnames(pheno) <<- c('latest_assembly','temp')
    phvals <<- t(pheno$temp)
    names(phvals) <<- pheno$latest_assembly
    charpaths<<-char2Paths(phvals, trees)
    
    genes <<- rownames(corrr)
    print(head(corrr))
    
    output$sidebar_ui_select <- renderUI({#generate UI elements
      selectizeInput(inputId='igene',
                     'Select a Gene',
                     choices = genes, 
                     selected='RAP1A')
    }) 
    igene <<- 'RAP1A'
    print(igene)
    print(head(corrr))
    output$corrr_table <- DT::renderDataTable({
      corrr %>% arrange(P)
    })
    

      
    })
  
  observeEvent(input$refresh_tree, { #refresh tree
    output$treeplot <- renderPlotly({ #populate trees
      igene <<- input$igene
      print(igene)
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
                       label = species, 
                       Tb = temp))
      
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
      
      plotly::subplot(t1, t2) %>% 
        layout(annotations = list(
          list(x = 0.05 , y = 0.95, text = "Average Gene Tree", showarrow = F, xref='paper', yref='paper'),
          list(x = 0.55 , y = 0.95, text = paste0(igene," Gene Tree"), showarrow = F, xref='paper', yref='paper'))
        )
    })
  })
  
  observeEvent(input$refresh_RER, { #refresh main plot
    output$RER_graph <- renderPlotly({ #populate any graphs necessary
      igene <<- input$igene
      subg <- which(!is.na(names(RERw[igene,which(!is.na(RERw[igene,]))])))
      subset <- RERw[igene,which(!is.na(RERw[igene,]))][subg]
      subset <- tibble(latest_assembly=names(subset), RER=subset) %>% mutate(idx=1:length(subset))
      subset <- left_join(subset, translate, by='latest_assembly') %>% 
        left_join(pheno, by='latest_assembly')
      
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
        add_markers(x=~RER, y=~idx, size=5, color=~sig, colors=c('blue','red','grey50'), text=paste0(subset$species,', Tb: ',subset$temp), hoverinfo= 'text' ) %>% 
        layout(title=paste0(igene,' Relative Evolutionary Rate'), yaxis=list(title='Branches'))
    })
  })
  
  observeEvent(input$refresh_cor, { #refresh main plot
    output$cor_graph <- renderPlotly({ #populate any graphs necessary
      igene <<- input$igene
      x <- charpaths
      y <- RERw[igene,]
      pathnames<-namePathsWSpecies(trees$masterTree)
      temp <- tibble(latest_assembly=pathnames, x=x, y=y)
      temp <- left_join(temp, translate, by='latest_assembly') %>% 
        left_join(pheno, by='latest_assembly')
      
      #line of best fit
      fv <- temp %>% filter(!is.na(y)) %>% filter(!is.na(species)) %>% lm(y ~ x,.) %>% fitted.values()
      
      #produce graph
      temp <- temp %>% filter(!is.na(y)) %>% filter(!is.na(species)) 
      temp %>% 
        plot_ly(x=~x) %>% 
        add_markers(y=~y, size=4, text=paste0(temp$species,' , Tb: ',temp$temp), hoverinfo= 'text') %>% 
        add_trace(x=~x, y=fv, mode='lines') %>% 
        layout(title=igene, xaxis=list(title='Normalized Body Temp'), yaxis=list(title='Relative Evolutionary Rate') )
    })
  })
  
})
