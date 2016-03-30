---
title: The evolution of Meedan's software stack
layout: post
---

Welcome to Meedan Code! In this inaugural post, we’re offering a retrospective about the software technologies that we’ve been using at Meedan over the years. We’ll have plenty of time to dig deeper into our current technology in upcoming posts; this one is just a quick fly-by.

Our software stack has evolved from humble beginnings to a modern architecture of interacting components that holds the promise of better stability, maintainability, and performance - and great fun to work on.

It was a natural genesis. In the beginning, Meedan’s only software consisted of an innovative news curation system that published article headers and user comments in English/Arabic translation. The web app had been hand-crafted in PHP by a small team of capable coders, and was hosted on a single, physical server located in Portland, which was managed by a part-time sysadmin. It worked great.

![Meedan's news app](/images/evolution-image_0.jpg)

Today, 6 years later, we are running a clusterable, containerized, code-generated, continuously-integrated deployment of 2 separate user-facing products, each with a backend made of multiple microservices, and supporting multiple front-end platforms. Whoa buzzword overdose! Beyond the hype, though, we gradually evolved to such an architecture out of necessity, with many stops and trials along the way from monolithic to distributed.

## The Drupal Way

Every Web programmer in the 2000s has written their share of hand-crafted PHP applications, performing essentially simple data processing functions but that required much more coding to implement stock administrative functionality, such as user and content management, form processing, and the like. This realization led to the proliferation of a much-loved and much-loathed species of Web apps, the CMS.

As a CMS, Drupal was among the most successful. It quickly attracted a strong user and developer community thanks to striking a fantastic balance between getting up and running in no time, and the ability to extend its functionality almost infinitely. I initially joined Meedan in 2011 as a Drupal contractor, and by then I had become quite adept at creating sophisticated applications (for the time) using this framework. Given Meedan’s budding contracts to create multilingual content annotation systems, Drupal seemed like a great fit and a logical replacement to the initial hand-crafted approach.

The transition succeeded, and within a few years our growing dev team had built 4 moderately complex applications using Drupal, enjoying daily usage and renewed funding. Along the way, we stretched what Drupal could do, made [numerous contributions to its community](https://www.drupal.org/node/2343639), and traveled to many exciting places worldwide. These were the simpler times.

![image alt text](/images/evolution-image_1.png)

![image alt text](/images/evolution-image_2.png)

## Complexity rears its ugly head; the new architecture

As our applications grew, we started facing scalability challenges with Drupal. These challenges manifested in many aspects, from code maintainability to lower performance and proliferation of defects. The whole Web was facing similar challenges, and [the realization was setting that the monolithic approach to building applications was largely responsible for this condition](https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy.md). In a nutshell, monolithic web apps are easy to build up to 1.0, but difficult to maintain in the face of growing traffic, evolving functionality and diverging platforms, while retaining correctness and performance. Heroic efforts were needed, and the myth of the rockstar coder was invented, to the detriment of all.

It was around that time that Meedan was given the opportunity to work on an ambitious prototype that would be delivered through a mobile iOS app, with a view to support other platforms down the road, including browsers. This was not your typical beer guzzling app, either: we quickly realized that the backend would require significant effort and a careful design. Right off the bat, Drupal sounded like a bad fit: it is frontend heavy and has trouble scaling. For a tech lead who only swore by Drupal previously, this was the closest I got to a severe case of Impostor’s Syndrome!

Fortunately, the Web was abuzz with API services and early stream processing systems, so we designed a simple architecture that would break the CMS into 2 main parts: an API to communicate with the mobile frontend, and a collection of background processes to populate and process the data model. We implemented the API using Ruby on Rails, trying to adhere to good REST design practices. As a background processing engine, we selected Apache Storm, for its ability to process streaming input, its neat abstraction of pipelines of computation steps, its clusterabilty, and many other attractive features.

![image alt text](/images/evolution-image_3.png)

## Explosion of the monolith

As the prototype received active usage, feature requests started pouring in. The product team was on fire! Many new features required additional backend functionality, which we all lumped together in the API layer. We were slowly recreating a monolith that performed many disparate tasks... Luckily, one specific feature called for the presentation of user data on web pages: it made us realize the API layer would not suit this functionality, and we designed instead a separate component to render and serve the HTML. For performance reasons, we decided on a file-based caching mechanism and avoided accessing the content database altogether. The existing backend would communicate with this rendering component via a simple API/webhook mechanism. This was our first microservice.

Since then, we’ve redesigned our apps’ architectures in terms of reusable, single-function services that can be developed and deployed independently. We have a number of them at various stages of production:

* A [monitor for web content](https://github.com/meedan/watchbot) that watches for changes and notifies its clients

* A [service that provides linguistic functionality](https://github.com/meedan/alegre), such as language identification, glossary / translation memory, machine translation, etc.

* A [cache-clearing service](https://github.com/meedan/cc-deville) that can interact with multiple layers of caches including Varnish, CloudFlare, etc.

* An [analytics service](https://github.com/meedan/copacabana) based on the Elastic stack

* A web media parsing and embedding service

* A Hubot that interfaces between various discussion systems (Slack, Twitter, etc.) and our core APIs

![image alt text](/images/evolution-image_4.png)

We’re enthusiastic about this approach for many reasons. As a very small dev team, we want to minimize dependencies, and allow each member to take charge of complete functionalities. By having the team negotiate API endpoints rather than struggle to untangle large codebases, we are able to move faster and delay the advent of complexity. Also, microservices allow team members to implement their functionalities in their language of choice, so long as they produce an API that complies with our standards. Finally, each service can be independently unit-tested and continuously-deployed with minimal down time.

To encourage good practices, we’ve developed an [API service generator](https://github.com/meedan/lapis) that encapsulates the qualities we want to infuse into our microservices. The generator uses tools such as Swagger and Docker to take care of most janitorial tasks and allow team members to focus on their functionalities. Our goal is to start all microservice development with this generator, and re-apply it to existing services as it evolves.

## On the horizon

Since we are still maintaining one of our "legacy" Drupal applications, we are considering migrating it to our microservice-based architecture. Because of resource and time constraints, we cannot afford to rewrite the whole thing from scratch in one go, while maintaining and adding features to the current codebase. We’re taking the following approach to organically decompose the monolith:

* Start treating Drupal as a front-end layer that delegates business processing to a set of microservices

* Identify self-contained functional areas in the current codebase and migrate each to a new or existing service. This includes reusing our own services listed above, using 3rd party services, or writing new ones. The Drupal front-end layer establishes bidirectional communication with these services via API calls and webhook notifications.

* Add an "façade" API layer to Drupal to allow richer clients to consume the content: mobile apps, browser extensions, etc.

* In time, all communication with Drupal will be conducted through the façade API, allowing us to finally unplug Drupal by rewriting the same API using our service generator.



We are only starting our journey with this new architectural approach, and I am certain we will encounter many new challenges. It’s an exciting time to be coding at Meedan, and I hope I was able to convey some of that excitement!
