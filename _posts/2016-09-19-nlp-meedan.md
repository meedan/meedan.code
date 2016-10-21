---
title: NLP at Meedan
layout: post
author: clarissa
---

This is the first of a series of posts about NLP (Natural Language Processing) work at Meedan. Meedan's NLP research and development focuses on solutions for adding value to our company's key products [Check](https://meedan.com/en/check) and [Bridge](https://meedan.com/en/bridge): collaborative systems for news verification and social media translation, respectively.

The NLP tools we developed at Meedan are gathered in an API called [Alegre](https://github.com/meedan/alegre). Alegre currently offers the following features: Language Identifier, Translation Memory, Glossary and Dictionary. We are particularly interested to develop solutions that run on a wide range of languages (including long-tail ones), that scale well and that run efficiently. In order to achieve these goals, the Translation Memory, Glossary and Dictionary features are implemented using [Elasticsearch](https://www.elastic.co/products/elasticsearch): an open source, distributed search engine. This tool gives us the performance and scalability we need, and it works with a  large number of languages, thanks to its multilingual [text analysis plugins](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-lang-analyzer.html).

Alegre works with an Elasticsearch schema that helps us achieve our goals:

- Each item (glossary term, translation entry, etc.) is stored in a field that's named according to the ISO 639 language code
- Each item is associated with a language analyzer corresponding to the item's language code (or the default analyzer if this language does not have its own, e.g. for small-community dialects)
- Each entry also includes a context field where we can add any valuable non-linguistic information such as project, user, source or geolocation.

The important point is that the contextual information can be changed according the needs of each project and Elasticsearch gives us the power to search with high performance within the context, even if it does not have a fixed structure. Below we present an excerpt of the Alegre schema as example:

{% highlight ruby linenos %}

{
  "alegre": {
    "mappings": {
      "glossary": {
        "properties": {
          "ar": {
            "type": "string",
            "analyzer": "arabic"
          },
          "es": {
            "type": "string",
            "analyzer": "spanish"
          },
          ...
          "context": {
            "properties": {
                "project": {"type": "string"},
                "user": {"type": "string"}
            }
          }
        }
      }
    }
  }
}
{% endhighlight %}

Next, we can see a Translation Memory document example, following the same type design.

{% highlight ruby linenos %}
{
         {
            "_index": "alegre",
            "_type": "translationMemory",
            "_id": "AVc0HS8lNHOnL_ufSvRr",
            "_source": {
               "en": "one car",
               "pt": "um carro",
               "context": {
                  "provider": "translation",
                  "project": "bridge",
                  "user": "ccx"
               }
            }
         }
}
{% endhighlight %}

And here a query searching for *one car* **(1)** pair in *Portuguese* **(2)** from the *translation provider* (context information) **(3)**.

{% highlight ruby linenos %}
POST alegre/translationMemory/_search?pretty=true
{
      "query": {
          "bool": {
              "must": [{
                  "match_phrase": {
                      "en": "one car" (1)
                      }
                },
                {
                  "match": {
                      "context.provider": "translation" (3)
                      }
                }],
                "filter": {
                  "exists" : { "field" : "pt" } (2)
              }                                    
          }              
      }
}
{% endhighlight %}

In the next post we will present Alegre's Language Identification feature. Stay tuned!
