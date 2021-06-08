FROM ruby:3.0.1-alpine3.13

RUN apk --update add --virtual build-dependencies make g++ && \
    apk update && apk add build-base && \
    apk add nodejs postgresql-dev tzdata && \
    mkdir /new-build

WORKDIR /new-build

ADD Gemfile.prod /new-build/Gemfile

ARG GEM_USERNAME
ARG GEM_PASSWORD
ARG ALLOWED_DOMAINS
ARG SECRET_KEY_BASE
ARG RAILS_MASTER_KEY

RUN bundle config gems.selise.tech ${GEM_USERNAME}:${GEM_PASSWORD}

RUN gem install bundler -v 2.2.18 && \
    bundle config set --local without 'development test' && \
    bundle install && \
    apk del build-dependencies &&  \
    rm -rf /var/cache/apk/* &&  \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete

ADD . /new-build

RUN mv /new-build/Gemfile.prod  /new-build/Gemfile && \
    mkdir -p /new-build/tmp/pids && \
    rm -rf /tmp/* /var/tmp/* && \
    RAILS_ENV=production bundle exec rails assets:precompile

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN  chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

