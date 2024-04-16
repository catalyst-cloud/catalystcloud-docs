FROM python:3.8-bookworm
LABEL authors="adrianjarvis"
ARG UID
ARG GID
ARG USERNAME
RUN mkdir /opt/catalystcloud-docs
WORKDIR /opt/catalystcloud-docs
COPY Makefile .
COPY requirements.txt .
COPY doc8.ini .
RUN pip install -r requirements.txt
RUN groupadd --gid $GID $USERNAME
RUN useradd --uid $UID --gid $GID $USERNAME
USER $UID:$GID

ENTRYPOINT ["make"]
CMD ["html",  "linkcheck"]