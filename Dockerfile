FROM continuumio/anaconda3


RUN conda install jupyter -y --quiet && \
    mkdir -p /home/jupyter/notebooks 

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini && \
    echo "12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini


# Create a new system user
#RUN useradd -ms /bin/bash jupyter
ADD ./startup.sh /startup.sh
RUN chmod +x /startup.sh

ADD ./jupyter_notebook_config.py /home/jupyter/.jupyter/jupyter_notebook_config.py

# Install any needed packages specified in requirements.txt
ADD ./requirements.txt requirements.txt
ADD ./artifactory-requirememts.txt artifactory-requirememts.txt
RUN pip3 install -r requirements.txt
#RUN pip3 install -r artifactory-requirememts.txt


# Set the container working directory to the user home #folder
#WORKDIR /home/jupyter
#ADD . /home/jupyter

#ADD notebook.json /home/jupyter/.jupyter/
#RUN chown jupyter:jupyter -R /home/jupyter/.jupyter

#USER jupyter


ENTRYPOINT ["tini", "-g", "--"]
CMD /startup.sh

