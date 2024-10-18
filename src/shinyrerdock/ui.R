library(tidyverse)
library(shiny)
library(shinythemes)
library(DT)
library(shinyjs)
library(plotly)
library(ggtree)
library(RERconverge)

options(shiny.maxRequestSize = 10000*1024^2)

ui <- shinyUI(navbarPage(title = "RER-Explorer (v1.0)",
                         theme=shinytheme('flatly'),
                         
                         tabPanel(title = "Summary",
                                  sidebarLayout(
                                    sidebarPanel(
                                      actionButton(inputId="run","Load Data"),
                                      hr(),
                                      uiOutput('sidebar_ui_select'),
                                      width = 3),
                                    
                                    mainPanel(
                                      hr(),
                                      DT::dataTableOutput('corrr_table'),
                                      hr(),
                                      width = 9)
                                    
                                  ) ),
                         
                         tabPanel(title = "Tree View",
                                  sidebarLayout(
                                    sidebarPanel(
                                      hr(),
                                      actionButton('refresh_tree','Refresh Tree'),
                                      
                                      width = 3),
                                    
                                    mainPanel(
                                      
                                      plotlyOutput("treeplot", height='1500px'),
                                      hr(),
                                      width = 9)
                                    
                                  ) ),
                         tabPanel(title = "RER",
                                  sidebarLayout(
                                    sidebarPanel(
                                      actionButton(inputId="refresh_RER","Refresh Graph"),
                                      hr(),
                                      
                                      width = 3),
                                    
                                    mainPanel(
                                      
                                      plotlyOutput("RER_graph", height='800px'),
                                      hr(),
                                      width = 9)
                                    
                                  ) ),
                         tabPanel(title = "Correlation",
                                  sidebarLayout(
                                    sidebarPanel(
                                      actionButton(inputId="refresh_cor","Refresh Graph"),
                                      hr(),
                                      
                                      width = 3),
                                    
                                    mainPanel(
                                      
                                      plotlyOutput("cor_graph", height='800px'),
                                      hr(),
                                      width = 9)
                                    
                                  ) )
)
)


