# Define base image
FROM continuumio/miniconda3
 
# Set working directory for the project
WORKDIR /app/
 
# Create Conda environment from the YAML filei
COPY environment-dev.yml .
RUN conda env create -f environment-dev.yml
 
# Override default shell and use bash:
SHELL ["conda", "run", "-n", "lume-live-dev", "/bin/bash", "-c"]
 
# Activate Conda environment and check if it is working properly
RUN echo "Making sure Key Packages are installed correctly..."
RUN python -c "import impact"
RUN echo ${PYTHONPATH}

#Convert Jupyter Notebooks to Python Files and Create Necessary Folders
RUN echo "Convert Jupyter Notebooks to Python Files and Create Necessary Folders"
SHELL ["conda", "run", "-n", "lume-live-dev", "jupyter nbconvert --to script lume-impact-live-demo.ipynb", "-c"]
SHELL ["conda", "run", "-n", "lume-live-dev", "jupyter nbconvert --to script make_dashboard.ipynb", "-c"]
SHELL ["conda", "run", "-n", "lume-live-dev", "jupyter nbconvert --to script get_vcc_image.ipynb", "-c"]

#Copy SourceCode
COPY . /app/
RUN mkdir -p /app/archive
RUN mkdir -p /app/output
RUN mkdir -p /app/plot
RUN mkdir -p /app/snapshot
RUN mkdir -p /app/log


# Python program to run in the container
ENTRYPOINT ["conda", "run", "-n", "lume-live-dev", "ipython", "lume-impact-live-demo.py"]
