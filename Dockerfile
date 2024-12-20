FROM ruby:3.3.2
RUN apt-get update && apt-get install -y build-essential
RUN curl -sL https://lib.chdb.io | bash
ENV LD_LIBRARY_PATH=/usr/local/lib
RUN gem install chdb pry

CMD ["/bin/bash"]
