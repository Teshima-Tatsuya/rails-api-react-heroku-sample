FROM ruby:2.4.1
ENV ROOT_DIR /app
ENV FRONTEND_DIR /app/frontend

RUN apt-get update && apt-get install -y mysql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev apt-utils
RUN apt-get update -qq && apt-get install -y libicu-dev cmake
RUN mkdir $ROOT_DIR
WORKDIR $ROOT_DIR

# init config
RUN echo "install: --no-document" >> ~/.gemrc
RUN echo "update: --no-document" >> ~/.gemrc

# install nodejs latest
RUN apt-get install -y nodejs npm
RUN npm install -g n
RUN n latest
RUN apt-get purge -y nodejs npm
RUN apt-get autoremove -y

# install yarn
RUN apt-get update -qq && apt-get install apt-transport-https -y
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -\
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn
RUN mkdir $FRONTEND_DIR
WORKDIR $FRONTEND_DIR
COPY frontend/package.json $FRONTEND_DIR
COPY frontend/yarn.lock $FRONTEND_DIR
RUN yarn install

# install bundle
WORKDIR $ROOT_DIR
COPY Gemfile $ROOT_DIR
COPY Gemfile.lock $ROOT_DIR
RUN gem install bundler
RUN bundle install --path vendor/bundle

ADD . $ROOT_DIR
