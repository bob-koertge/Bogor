Given(/^As an Agent, I reply to an email case$/) do


end

Given(/^I am logged into to agent v3$/) do
  desk_qa_helper = DeskQATestHelper.new $data_store, $browser
  expect(desk_qa_helper.login('web/agent')).to eql(true)
end

/html/body/section/section/section[2]/section[2]/section/section/section/section/div[2]/table/tbody/tr[2]/td[3]/div/div/div/div[2]/span[1]/text()