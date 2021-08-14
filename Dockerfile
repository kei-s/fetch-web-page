FROM ruby:3

WORKDIR /fetch
COPY Gemfile* ./
RUN bundle install
COPY fetch.rb ./fetch
COPY serve.rb ./serve
RUN chmod +x fetch serve
ENTRYPOINT [ "bash" ]
