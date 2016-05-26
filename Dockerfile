
# code.meedan.com
# a technology blog built using the jeckyll cms

FROM jekyll/jekyll:pages
# https://github.com/jekyll/docker/wiki

MAINTAINER sysops@meedan.com
ENV IMAGE meedan/code-blog
ENV DEPLOYUSER codeblog 
ENV DEPLOYDIR /app 

RUN adduser $DEPLOYUSER -D -s /bin/nologin
RUN gem install jekyll

COPY ./ $DEPLOYDIR
RUN chown -R $DEPLOYUSER:$DEPLOYUSER $DEPLOYDIR

WORKDIR $DEPLOYDIR
USER $DEPLOYUSER
RUN jekyll build

EXPOSE 4000
ENTRYPOINT ["jekyll","serve"]