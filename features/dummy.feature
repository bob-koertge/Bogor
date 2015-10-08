Feature: Test bed for new stuff

  Background:
    Given I create a new site via api
    And I seed 5 emails

  Scenario: Create a new site via API
    Then the site should exist
