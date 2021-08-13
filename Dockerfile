FROM ruby:3

WORKDIR /fetch
COPY Gemfile* ./
RUN bundle install
COPY fetch.rb ./fetch
RUN chmod +x fetch
ENTRYPOINT [ "bash" ]
