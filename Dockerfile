FROM ruby:3

WORKDIR /fetch
COPY fetch.rb ./fetch
RUN chmod +x fetch
ENTRYPOINT [ "bash" ]
