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
RUN conda run -n lume-live-dev jupyter nbconvert --to script ./lume-impact-live-demo.ipynb
RUN conda run -n lume-live-dev jupyter nbconvert --to script ./make_dashboard.ipynb
RUN conda run -n lume-live-dev jupyter nbconvert --to script ./get_vcc_image.ipynb

#Copy SourceCode
COPY . /app/

SHELL ["mkdir", "-p", "/app/archive"]
SHELL ["mkdir", "-p", "/app/output"]
SHELL ["mkdir", "-p", "/app/plot"]
SHELL ["mkdir", "-p", "/app/snapshot"]
SHELL ["mkdir", "-p", "/app/log"]


# Python program to run in the container
ENTRYPOINT ["conda", "run", "-n", "lume-live-dev", "ipython", "/app/lume-impact-live-demo.py"]
