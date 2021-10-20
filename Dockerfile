FROM debian:bullseye-slim

# Install system libraries first as root
USER root

RUN apt-get update \
 && apt-get install -y build-essential autoconf curl wget unzip procps jq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install Anaconda python
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN pip3 install --upgrade pip

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1


RUN echo "$LOG_TAG Install jupyter" && \
    pip install --upgrade jsonschema && \
    pip install --upgrade jsonpointer && \
    pip install jupyter
#    pip install toree

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini && \
    echo "12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini


# Create a new system user
RUN useradd -ms /bin/bash jupyter
ADD ./startup.sh /startup.sh
RUN chmod +x /startup.sh

ADD ./jupyter_notebook_config.py /home/jupyter/.jupyter/jupyter_notebook_config.py

# Install any needed packages specified in requirements.txt
ADD ./requirements.txt requirements.txt
ADD ./artifactory-requirememts.txt artifactory-requirememts.txt
RUN pip3 install --trusted-host pypi.python.org -r requirements.txt
RUN pip3 install -r artifactory-requirememts.txt


# Set the container working directory to the user home #folder
WORKDIR /home/jupyter
ADD . /home/jupyter

#RUN jupyter toree install --spark_home=$SPARK_HOME --interpreters=Scala,PySpark,SparkR,SQL
#RUN jupyter contrib nbextension install --system
ADD notebook.json /home/jupyter/.jupyter/
RUN chown jupyter:jupyter -R /home/jupyter/.jupyter
#RUN jupyter contrib nbextension install --sys-prefix
#RUN jupyter nbextensions_configurator enable --system

USER jupyter


ENTRYPOINT ["tini", "-g", "--"]
CMD /startup.sh

