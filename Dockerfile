#start with rocker/shiny-verse 
FROM rocker/shiny-verse:latest
  RUN mkdir -p /data
  RUN mkdir -p /src/shiny
  RUN mkdir -p /logs
  RUN mkdir -p /srv/shiny-server/shinyrer

  ## copy files
  COPY ["src/shinyrerdock/ui.R", "/src/shiny/ui.R"]
  COPY ["src/shinyrerdock/server.R", "/src/shiny/server.R"]

  ## install libs
  RUN apt-get update && apt-get install -y vim libssl3 lsof htop libglpk40
  RUN ["R", "-e", "devtools::install_github('nclark-lab/RERconverge')"]
  RUN ["R", "-e", "install.packages(c('shinyjs','shinythemes','plotly','rclipboard','DT','BiocManager'), dependencies=TRUE)"]
  RUN ["R", "-e", "BiocManager::install('ggtree')"]
  #RUN R -e "BiocManager::install('ComplexHeatmap')"
  

  #add some missing tools
  #RUN ["apt-get", "update"]
  #RUN ["apt-get", "install", "-y", "vim"]
  #RUN ["apt-get", "install", "-y", "libssl3"]
  #RUN ["apt-get", "install", "-y", "lsof"]

  #copy app to server location,must be single file
  RUN cat /src/shiny/ui.R /src/shiny/server.R > /srv/shiny-server/shinyrer/app.R
  RUN echo "\nshinyApp(ui = ui, server = server)" >> /srv/shiny-server/shinyrer/app.R

  #show port to host
  EXPOSE 3838

  ## run the server ...
  #CMD is the command that starts the service when container runs
  CMD /usr/bin/shiny-server
