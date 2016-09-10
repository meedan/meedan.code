---
title: A Dockerized development environment ftw
layout: post
author: karim
---

Our adventures with building distributed, service-based applications are pushing us to resolve long-standing issues that were often relegated to the back-burner with monolithic apps. The issue I'd like to focus on today is provisioning a reproducible development environment across team members.

Our app of interest is currently made up of the following pieces:
- A Ruby on Rails service that delivers the main app business logic via REST and GraphQL endpoints
- Another RoR service that provides a generic, self-contained function
- A React app that consumes the main API
- A PostgreSQL database
- An Elasticsearch database
- ...with at least 3 more services on the way

Thanks to years of evangelizing and leadership by my colleague Caio Almeida, all backend services that we write are now routinely unit-tested, code-linted, and auto-documented. On the frontend, we use Ruby's `rspec` to drive behavioural tests through Selenium/ChromeDriver. Unit tests for the frontend are underway :-)

This is not a trivial architecture, and yet we want the whole dev team to be able to run this application on their local machine. Bear in mind that the dev team includes members with widely varying software backgrounds and skills: hardcore software engineers, frontend coders, UI designers, even computational linguists in our case! It would be significantly inefficient to expect all these people to master the intricacies of locally deploying each service, and to resolve integration problems that are specific to their own machine! Indeed, the previous distributed app that we wrote (which was our first) has only ever been developed by a single team member, and now that another dev has joined to help maintain it, we are facing a challenging handover issue that I have good hope will be made easier by our solution below.
