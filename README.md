# shinyrer

Steps to install
- `docker pull dbioinfo/shinyrer`
- unzip shipping_container.zip into a directory called tmp/
- `docker run -p 3838:3838 -v ./tmp:/data dbioinfo/shinyrer`
- go to http://localhost:3838/shinyrer/

