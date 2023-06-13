# Define base image
FROM continuumio/miniconda3
 
# Set working directory for the project
WORKDIR /
 
# Create Conda environment from the YAML filei
COPY environment-dev.yml .
RUN conda env create -f environment-dev.yml
 
# Override default shell and use bash:
SHELL ["conda", "run", "-n", "lume-live-dev", "/bin/bash", "-c"]
 
# Activate Conda environment and check if it is working properly
RUN echo "Making sure Key Packages are installed correctly..."
RUN python -c "import impact"
RUN echo ${PYTHONPATH}
COPY make_dashboard.py .
COPY get_vcc_image.py .
RUN python -c "import make_dashboard"
 

# Python program to run in the container
COPY lume-impact-live-demo.py .
ENTRYPOINT ["conda", "run", "-n", "lume-live-dev", "ipython", "lume-impact-live-demo.py"]
