
# Base image
FROM ubuntu:24.04
MAINTAINER Paul Murrell <paul@stat.auckland.ac.nz>

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=NZ
RUN apt-get update && apt-get install -y tzdata

# Building R from source
RUN apt-get update && apt-get install -y \      
    subversion \
    r-base-dev \
    texlive-full \
    libcairo2-dev \
    libpcre2-dev \
    libcurl4-openssl-dev
# Get R commit r
RUN svn co -r89300 https://svn.r-project.org/R/trunk/ R
RUN cd R; ./configure --with-x=no --without-recommended-packages 
RUN cd R; make

# For building the report
RUN apt-get update && apt-get install -y \
    xsltproc \
    bibtex2html 
RUN apt-get install -y \
    libxml2-dev \
    libssl-dev \
    libssh2-1-dev \
    libgit2-dev 
RUN apt-get install -y \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libwebp-dev 
RUN R/bin/Rscript -e 'install.packages("devtools", repos="https://cran.rstudio.com/")'
RUN R/bin/Rscript -e 'library(devtools); install_version("knitr", "1.51", repos="https://cran.rstudio.com/")'
RUN R/bin/Rscript -e 'library(devtools); install_version("xml2", "1.5.1", repos="https://cran.rstudio.com/")'

# Packages used in the report
RUN apt-get update && apt-get install -y \
    gfortran \
    cmake \
    libudunits2-dev \
    libabsl-dev \
    libgdal-dev
RUN R/bin/Rscript -e 'library(devtools); install_version("sf", "1.0.24", repos="https://cran.rstudio.com/")'
RUN R/bin/Rscript -e 'library(devtools); install_version("dplyr", "1.1.4", repos="https://cran.rstudio.com/")'
RUN R/bin/Rscript -e 'library(devtools); install_version("ggplot2", "4.0.1", repos="https://cran.rstudio.com/")'
RUN R/bin/Rscript -e 'library(devtools); install_version("gggrid", "0.2.0", repos="https://cran.rstudio.com/")'

# The main report package(s)
RUN R/bin/Rscript -e 'library(devtools); install_version("hexView", "0.3.4", repos="https://cran.rstudio.com/")'
COPY xdvir_0.2-0.tar.gz /tmp
RUN R/bin/R CMD INSTALL /tmp/xdvir_0.2-0.tar.gz

RUN apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV TERM=dumb
