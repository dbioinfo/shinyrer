## Installation Guide

Follow these steps to install and run the application:

### Prerequisites
- A terminal/command line interface
- Internet connection

### Installation Steps

1. Install Docker using snap:
   ```bash
   snap install docker
   ```

2. Pull the Docker image:
   ```bash
   docker pull dbioinfo/shinyrer
   ```

3. Unzip the provided data:
   ```bash
   unzip shipping_container.zip -d tmp/
   ```
   This will extract the contents into a directory called `tmp/`

4. Run the Docker container:
   ```bash
   docker run -p 3838:3838 -v ./tmp:/data dbioinfo/shinyrer
   ```
   This command:
   - Maps port 3838 from the container to your local machine
   - Mounts the local `tmp/` directory to `/data` in the container

5. Access the application:
   Open your web browser and navigate to:
   ```
   http://localhost:3838/shinyrer/
   ```

### Troubleshooting

- If you encounter permission issues with Docker, you may need to run the commands with `sudo`
- Ensure ports are not already in use by another application
