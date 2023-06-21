# Define base image
#FROM centos:centos7
FROM continuumio/miniconda3

# Set working directory for the project
WORKDIR /app/

RUN apt-get update && apt install gfortran -y

RUN git clone https://github.com/impact-lbl/IMPACT-T.git /app/

# Create Conda environment from the YAML filei
COPY lume-live-dev.yml .
RUN conda env create -f lume-live-dev.yml   

# Override default shell and use bash:
SHELL ["conda", "run", "-n", "lume-live-dev", "/bin/bash", "-c"]

# Activate Conda environment and check if it is working properly
RUN echo "Making sure Key Packages are installed correctly..."
RUN python -c "import impact"
RUN echo ${PYTHONPATH}

#Copy SourceCode
COPY . /app/

RUN echo "Installing Impact-T seperately"
ENV PATH="$PATH:/opt/conda/bin"

RUN ls -a /root/

SHELL ["/bin/bash", "-c"]

RUN ls -a ~

RUN conda info | grep -i 'base environment'

RUN source ~/.bashrc \
    && source /opt/conda/etc/profile.d/conda.sh \
    && /opt/conda/bin/activate && conda init bash \ 
    && conda activate lume-live-dev && conda install -c anaconda cmake \
    && conda install -c conda-forge impact-t=*=mpi_openmpi*

RUN echo "Check if Impactexe and Impactexe-mpi are installed"
RUN ls -ltr /opt/conda/envs/lume-live-dev/bin/ | grep "Impact"

# SHELL ["mkdir", "-p", "/app/archive"]
# SHELL ["mkdir", "-p", "/app/output"]
# SHELL ["mkdir", "-p", "/app/plot"]
# SHELL ["mkdir", "-p", "/app/snapshot"]
# SHELL ["mkdir", "-p", "/app/log"]

# #Convert Jupyter Notebooks to Python Files and Create Necessary Folders
# RUN echo "Convert Jupyter Notebooks to Python Files and Create Necessary Folders"
# RUN conda run -n lume-live-dev jupyter nbconvert --to script /app/lume-impact-live-demo.ipynb
# RUN conda run -n lume-live-dev jupyter nbconvert --to script /app/make_dashboard.ipynb
# RUN conda run -n lume-live-dev jupyter nbconvert --to script /app/get_vcc_image.ipynb

# # Python program to run in the container
# ENTRYPOINT ["conda", "run", "-n", "lume-live-dev", "ipython", "/app/lume-impact-live-demo.py"]
