Feature: Test bed for new stuff

  Background:
    Given I create a new site via api
    And I seed 1 static email

  Scenario: Agent v3 - Agent replies to a case
    Given I wait for postmark to send in first case
    And I am logged into to agent v3
    When As an Agent, I reply to an email case

