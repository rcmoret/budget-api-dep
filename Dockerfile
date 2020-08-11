FROM ruby:2.6.3

WORKDIR /app
COPY . /app

RUN gem install bundler

RUN bundle install

CMD ["bundle", "exec", "rake"]
