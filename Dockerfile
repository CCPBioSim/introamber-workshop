# Intro Amber Workshop

# Start with the base container for the JupyterHub image
FROM jupyter/base-notebook

LABEL maintainer="Sarah Fegan <sarah.fegan@stfc.ac.uk>"

# Root to install things
USER root

# Update and install software dependencies needing root
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    bc \
    bison \
    cmake \
    csh \
    sed \
    flex \
    gcc \
    gfortran \
    git \
    g++ \
    libbz2-dev \
    make \
    nano \
    openssh-client \
    patch \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-dev \
    rsync \
    vim \
    wget \
    zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Update pip
RUN python3 -m pip install --upgrade pip

# Install Ambertools
ENV AMBERHOME=/opt/amber18

COPY AmberTools19.tar.bz2 /opt
RUN cd /opt && \
    tar xvfj AmberTools19.tar.bz2 && \
    rm AmberTools19.tar.bz2 && \
    cd amber18 && \
    echo 'Y' | ./configure --with-python /usr/bin/python3 -noX11 gnu && \
    . ./amber.sh && make install && \
    chown -R $NB_USER:$NB_GID /opt/amber18

# Export important paths
ENV PATH=/home/jovyan/.local/bin:$PATH
ENV PATH=/opt/amber18/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/amber18/lib64:$LD_LIBRARY_PATH

# Back to jovyan user
USER $NB_USER
WORKDIR $HOME

# Remove work directory
RUN rm -r $HOME/work

# Python Dependencies for the workshop
RUN pip install --user numpy
RUN pip install --user mdtraj

# Install Jupyterhub plugins
RUN pip install jupyterhub-tmpauthenticator
RUN pip install --user ipywidgets
RUN pip install --user nglview

# Initialise NGLView
RUN jupyter-nbextension install nglview --py --sys-prefix && \
    jupyter-nbextension enable nglview --py --sys-prefix && \
    pip install fileupload && \
    jupyter-nbextension install fileupload --py --sys-prefix && \
    jupyter-nbextension enable fileupload --py --sys-prefix

# Add all of the workshop files to the home directory
RUN git clone https://github.com/CCPBioSim/introamber-workshop.git
RUN mv introamber-workshop/* . && \
    rm -r Dockerfile LICENSE README.md introamber-workshop

# UNCOMMENT THIS LINE FOR REMOTE DEPLOYMENT
#COPY jupyter_notebook_config.py /etc/jupyter/

# Always finish with non-root user as a precaution.
USER $NB_USER
