---
title: Language identification using Alegre
layout: post
author: clarissa
---

The article [Automatic Bilingual Language Identification in Short, Noisy Texts](/files/meedan_langid.pdf) presents a language identification solution designed to deal with noisy and short texts. The identifier is implemented as part of Meedan linguistic server [Alegre](https://github.com/meedan/alegre) and it is affectionately known as `langid`.

It works identifying one language or pairs of languages. In case of pairs, one of the languages is assumed to be English.  The presented solution combines TF-IDF VSM similarity of character 3-grams with heuristics for single language identification and uses words 3-grams windows for bilingual identification.
