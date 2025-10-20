# Start with BioSim base image.
ARG BASE_IMAGE=latest
FROM ghcr.io/ccpbiosim/jupyterhub-base:$BASE_IMAGE

LABEL maintainer="James Gebbie-Rayet <james.gebbie@stfc.ac.uk>"

ARG TARGETPLATFORM

# Switch to jovyan user.
USER $NB_USER
WORKDIR $HOME

# Export important paths.
ENV AMBERHOME=/opt/conda

# Install dependencies
RUN conda install numpy ipywidgets nglview compilers -y
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      conda install conda-forge::ambertools -y; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      mamba install conda-forge/osx-arm64::ambertools -y; \
    fi
RUN pip install mdtraj

# Get workshop files and move them to jovyan directory.
COPY --chown=1000:100 . .
RUN rm -rf LICENSE README.md docker .git .github

# Copy lab workspace
COPY --chown=1000:100 docker/default-37a8.jupyterlab-workspace /home/jovyan/.jupyter/lab/workspaces/default-37a8.jupyterlab-workspace

# Always finish with non-root user as a precaution.
USER $NB_USER
