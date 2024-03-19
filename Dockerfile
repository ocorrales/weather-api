FROM ruby:3.2-alpine

WORKDIR  /app

COPY Gemfile* ./
COPY app.rb ./

#Updating default image with needed development tool needed for ffi
RUN apk add --update build-base gcc musl-dev libffi-dev zlib-dev
RUN bundle install
RUN apk add --no-cache curl


EXPOSE 4567

CMD [ "ruby","app.rb", "-o","0.0.0.0" ]