
# code.meedan.com
# a technology blog built using the jeckyll cms

FROM meedan/ruby
# https://github.com/meedan/docker-hub/tree/master/meedan/ruby

MAINTAINER sysops@meedan.com
ENV IMAGE meedan/code-blog
ENV DEPLOYUSER codeblog 
ENV DEPLOYDIR /app 

RUN adduser $DEPLOYUSER --shell /bin/nologin

COPY ./Gemfile $DEPLOYDIR/Gemfile
COPY ./Gemfile.lock $DEPLOYDIR/Gemfile.lock
RUN chown -R $DEPLOYUSER:$DEPLOYUSER $DEPLOYDIR

WORKDIR $DEPLOYDIR
# its not great form to install as root but unfortunately jekyll does not jive with the `bundle install --deployment` method
RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc \
    && bundle install --without test development

COPY ./ $DEPLOYDIR
RUN chown -R $DEPLOYUSER:$DEPLOYUSER $DEPLOYDIR

USER $DEPLOYUSER
RUN jekyll build

EXPOSE 4000
ENTRYPOINT ["jekyll","serve","--host=0.0.0.0"]