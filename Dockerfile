FROM ruby:3.0.0-alpine3.12

RUN apk --update add --virtual build-dependencies make g++ && \
    apk update && apk add build-base && \
    apk add nodejs postgresql-dev && \
    mkdir /new-build

WORKDIR /new-build

ADD Gemfile.prod /new-build/Gemfile

ARG GEM_USERNAME
ARG GEM_PASSWORD

RUN bundle config gems.selise.tech ${GEM_USERNAME}:${GEM_PASSWORD}

RUN gem install bundler -v 2.2.14 && \
    bundle config set --local without 'development test' && \
    bundle install && \
    apk del build-dependencies &&  \
    rm -rf /var/cache/apk/* &&  \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete

ADD . /new-build

ADD Gemfile.prod  /new-build/Gemfile
RUN rm -fr /new-build/log && mkdir /new-build/log
COPY entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    mkdir -p tmp/pids

ENTRYPOINT ["entrypoint.sh"]
