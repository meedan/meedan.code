---
title: A Dockerized development environment ftw
layout: post
author: karim
---

Our adventures with building distributed, service-based applications are pushing us to resolve long-standing issues that were often relegated to the back-burner with monolithic apps. The issue I'd like to focus on today is provisioning a reproducible development environment across team members.

Our app of interest is currently made up of the following pieces:
- A Ruby on Rails service `check-api` that delivers the main app business logic via REST and GraphQL endpoints
- Another RoR service `pender` that provides the specialized functionality of parsing and embedding URLs
- A React app `check-web` that consumes the main API
- A PostgreSQL database
- An Elasticsearch index
- ...and several more smaller client apps

Thanks to years of evangelizing and leadership by our colleague Caio Almeida, all backend services that we write are now routinely unit-tested, code-linted, and auto-documented. On the frontend, we use Ruby's `rspec` to drive behavioural tests through Selenium/ChromeDriver. Unit tests for the frontend are underway :-)

This is not a trivial architecture, and yet we want the whole dev team to be able to run (and hack on) this application on their local machine. Bear in mind that the dev team includes members with widely varying software backgrounds and skills: hardcore software engineers, frontend coders, UI designers, even computational linguists in our case! It would be significantly inefficient to expect all these people to master the intricacies of locally deploying each service, and to resolve integration problems that are specific to their own machine. Indeed, the previous distributed app that we wrote (which was our first at Meedan) had only ever been developed by a single team member, and scaling up the dev team, we faced a challenging knowledge transfer issue that has been largely resolved using our current approach.

In a nutshell, we are using `docker-compose` to assemble the app in a host-agnostic manner, allowing the team to run the app, to modify parts of it without having to restart the whole infrastructure, and to run all tests reliably. Of course, the devil is in the details, and here are the details of our setup.

## Overview of the Docker Compose configuration

## Dockerized Ruby on Rails service for local development

## Dockerized React application for local development

## Dockerized behavioural testing using Selenium

## Dockerized configuration secrets
