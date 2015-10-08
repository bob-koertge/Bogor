
Feature: Verify that all status endpoints are functional


  Scenario: Verify Poll status point
    Given I am on a new site
    When I request the status of poll
    Then The system returns the current status

