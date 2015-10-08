
Feature: Verify that all status endpoints are functional

  Scenario: Verify Portal status point
    Given I am on a new site
    When I request the status of portal
    Then The system returns the current status