---
title: How we've been fixing our flaky Selenium suite
layout: post
author: caiosba
---

In which we demonstrate a technique to reliably target DOM elements in spite of React's behind-the-scenes manipulations.

## The Context

Here at Meedan we try to write automated tests for all our applications, on both backend and frontend, as our [Travis](https://travis-ci.org/meedan){:target="_blank", rel="noopener noreferrer"} page shows. On most applications, like [Check API](https://github.com/meedan/check-api){:target="_blank", rel="noopener noreferrer"} and [Check Bot](https://github.com/meedan/check-bot){:target="_blank", rel="noopener noreferrer"} we even have 100% test coverage. Our test suite should not only be as complete as possible, but also stable - e.g., tests should pass or fail consistently.


## The Problem

Tests that fail sometimes but not always are a universal and old problem, especially in UI testing. Those are called :snowflake: _flaky tests_. We've been facing this problem for a long time in the test suite of [Check Web](https://github.com/meedan/check-web){:target="_blank", rel="noopener noreferrer"}, our web (and main) client written in React.js, for [Check](http://meedan.com/en/check){:target="_blank", rel="noopener noreferrer"}. That test suite is written in [Ruby and uses Selenium webdriver](https://rubygems.org/gems/selenium-webdriver/versions/2.53.0){:target="_blank", rel="noopener noreferrer"}. A flaky test suite is frustrating, slows down our development cycle (since we only merge code to the main branch when the test build passes) and reduces our confidence in the test suite.

## The Solution

Most steps of our tests involve waiting for elements to be present on the page. We used to wait for elements to be present using the regular `Wait` from Selenium's library:

```ruby
wait = Selenium::WebDriver::Wait.new
element = wait.until { @driver.find_element(:css, '.target') }
```

The problem with this approach is that, in many (random) cases, the `element` is not actually attached to the DOM (yet or anymore), and thus we can get stale reference to the `element` when we use it later. The `find_element` itself doesn't guarantee that the returned element it not stale. But if you call the `displayed?` method, then an [exception](https://docs.seleniumhq.org/exceptions/stale_element_reference.jsp){:target="_blank", rel="noopener noreferrer"} will be thrown if the element is stale. This is particularly common in React.js, where the UI is re-rendered very often, causing the element to pop in and out of the DOM unexpectedly.

Our solution was to implement our own version of a method that waits until an element is really attached to the page and returns it:

```ruby
def wait_for_selector(selector, type = :css, max_attempts = 10, wait = 1)
  element = nil
  attempts = 0
  while element.nil? && attempts < max_attempts do
    attempts += 1
    begin
      element = @driver.find_element(type, selector)
      element.displayed?
    rescue
      element = nil
    end
    sleep wait
  end
  element
end
```

This method looks for an element using a `selector`, which can be of `type` CSS, XPath, etc. When Selenium returns the element to us, we check if it's stale or not, by calling the `displayed?` method. If it's stale, an exception will be thrown, which we'll catch and `wait` until we try again, up to a `max_attempts` times.

After this fix, our last five builds on [Travis](https://travis-ci.org/meedan/check-web/builds){:target="_blank", rel="noopener noreferrer"} ran successfully. So far, so good. If this stability is confirmed, we'll be able to change the title of this blog post from "How we've been fixing..." to "How we have fixed..." :crossed_fingers:
