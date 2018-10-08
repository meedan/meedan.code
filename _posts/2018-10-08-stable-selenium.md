---
title: How we've been fixing our flaky Selenium suite
layout: post
author: caiosba
---

## The Context

Here at [Meedan](https://meedan.com) we try to write automated tests for all our applications, on both backend and frontend sides, as our [Travis](https://travis-ci.org/meedan) page shows. On most applications, like [Check API](https://github.com/meedan/check-api) and [Check Bot](https://github.com/meedan/check-bot) we even have 100% test coverage. Our test suite should not only be as complete as possible, but also stable - e.g., tests should pass or fail consistently.


## The Problem

Tests that fail sometimes but not always are a universal and old problem, especially in UI testing. Those are called _flaky tests_. We've been facing this problem for a long time in the test suite of [Check Web](https://github.com/meedan/check-web), our web (and main) client written in [React.js](https://reactjs.org/), for [Check](http://meedan.com/en/check). That test suite is written in [Ruby and uses Selenium webdriver](https://rubygems.org/gems/selenium-webdriver/versions/2.53.0). A flaky test suite is frustrating, slows down our development cycle (since we only merge code to the main branch when the test build passes) and reduces our confidence on the test suite.

## The Solution

Most steps of our tests involve waiting for elements to be present on the page. We used to wait for elements to be present by using the regular `wait` from Selenium's library:

```ruby
wait = Selenium::WebDriver::Wait.new
element = wait.until { @driver.find_element(:css, '.target') }
```

The problem with this approach is that, in many (random) cases, the `element` is not actually attached to the DOM (yet or anymore), and thus we can get stale reference to the `element` when we use it later. The `find_element` itself doesn't guarantee that the returned element it not stale. But if you call the `displayed?` method, then an [exception](https://docs.seleniumhq.org/exceptions/stale_element_reference.jsp) will be thrown if the element is stale. This is particularly common on React.js, where the UI is re-rendered very often.

Our final solution was to implement our own version of a method that waits until an element is really attached to the page and returns it:

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

After this fix, our last five builds on [Travis](https://travis-ci.org/meedan/check-web/builds) ran successfully. So far, so good. If this stability is confirmed, we'll be able to change the title of this blog post from "How we've been fixing" to "How we have fixed" :).
