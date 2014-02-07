Given(/^there is a user in a group$/) do
  @user = FactoryGirl.create(:user, name: "Marge", 
                              email: "marge@large.org")
  @group = FactoryGirl.create :group
  @membership = @group.add_member! @user
end

When(/^their account is deactivated$/) do
  @user.deactivate!
end

Then(/^the user's deleted_at attribute should be set$/) do
  User.where("deleted_at IS NOT NULL").should exist
end

And(/^the user's email notifications should be turned off$/) do
  @user.email_preferences.subscribed_to_daily_activity_email.should == false
  @user.email_preferences.subscribed_to_mention_notifications.should == false
  @user.email_preferences.subscribed_to_proposal_closure_notifications.should == false
  @user.email_preferences.days_to_send.should be_empty
end

And(/^the user's memberships should be archived$/) do
  @membership.reload
  @membership.archived_at.should_not be_nil
end

When (/^they attempt to sign in$/) do
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'password'
  click_on 'sign-in-btn'
end

Then (/^they should be told their account is inactive$/) do
  page.should have_content'Sorry, this account is currently inactive'
end
