# Meedan Code
Meedan's software blog, using `jekyll`.

## How to write a post

- Clone this repo on the `develop` branch
- Start Jekyll locally with `jekyll serve`
- Open a new file in `/_posts`, named as `YYYY-MM-DD-slug.md` where the date prefix will be used as publishing date
- Posts are typically written in Markdown format - [read this for a good intro](https://jekyllrb.com/docs/posts/)
- Add a YAML header like the following:
```
---
title: A Dockerized development environment ftw
layout: post
author: karim
---
```
- Ensure that you, the author, exist in `/_data/people.yml`
- Place your post's image files in `/images` - right now all post images are mixed together
- Push to `develop`: your post will appear at http://code.dev.meedan.com/
- Ask an admin to publish to https://code.meedan.com/
