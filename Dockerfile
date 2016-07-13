
# code.meedan.com
# a technology blog built using the jeckyll cms

FROM meedan/ruby
# https://github.com/meedan/docker-hub/tree/master/meedan/ruby

MAINTAINER sysops@meedan.com
ENV IMAGE meedan/code-blog
ENV DEPLOYUSER codeblog 
ENV DEPLOYDIR /app 

RUN adduser $DEPLOYUSER --shell /bin/nologin

RUN gem install jekyll

COPY ./ $DEPLOYDIR
RUN chown -R $DEPLOYUSER:$DEPLOYUSER $DEPLOYDIR

# link to where the binary will be put
# RUN ln -s /app/vendor/bundle/ruby/2.3.0/bin/jekyll /usr/local/bin/jekyll

USER $DEPLOYUSER
WORKDIR $DEPLOYDIR
RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc \
    && bundle install --deployment

RUN jekyll build

EXPOSE 4000
ENTRYPOINT ["jekyll","serve","--host=0.0.0.0"]