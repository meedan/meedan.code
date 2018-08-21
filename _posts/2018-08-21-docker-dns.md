---
title: How to use gcloud in a Docker container when your DNS resolves .internal domains
layout: post
author: caiosba
---

## The Context

Here at [Meedan](https://meedan.com) we were trying to automate the deployment of a legacy application to Google Cloud. This application used the old `appcfg` command from Google Cloud SDK and required the user to login manually on Google, in the browser, in order to proceed with deployment. This was not feasible for us because we wanted to automate the deployment with Jenkins and to do that from inside a Docker container, in the cloud.

So, we replaced `appcfg` by `gcloud` and used its ability to authenticate using the JSON keys file for a services account. This way, it was not necessary to open the browser to login and we could deploy using a Docker container.

## The Problem

So far so good. Worked well on our personal machines, but didn't work when we tried to run the Docker container from a server in the cloud. The error when we ran `gcloud` was:

```
ERROR: gcloud crashed (CertificateError): hostname 'metadata.google.internal' doesn't match 'vpn.fatmac.co.uk'
```

This happens because `gcloud` resolves `metadata.google.internet` in order to verify if it's running inside Google Cloud or not. In our case, it thought it was running in Google Cloud because our datacenter DNS resolves any `*.internal` domain, but resolved to something that `gcloud` was not expecting, thus the error.

Looks like [we were not the only one facing this problem](https://github.com/GoogleCloudPlatform/cloud-sdk-docker/issues/111).

## The Solution

Since we didn't have access to fix it at the DNS level, the solution was to set a different DNS configuration for the Docker container. We could do that by providing additional parameters to the `docker run` command:

```
--dns=8.8.8.8 --dns-search=.
```

This way, the Docker container used `8.8.8.8` instead of the DNS of the host machine and the problem was solved.
