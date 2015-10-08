
Feature: Verify that all status endpoints are functional

  Scenario: Verify API status point
    Given I am on a new site
    When I request the status of api
    Then The system returns the current status
