Then /^the git remote will( not)? have the commit "(.+)"$/ do |negate, message|
  commits = git_commits(fake_git_remote)

  if negate
    expect(commits).to_not include(message)
  else
    expect(commits).to include(message)
  end
end

Then /^the git remote will( not)? have the tag "(.+)"$/ do |negate, tag|
  tags = git_tags(fake_git_remote)

  if negate
    expect(tags).to_not include(tag)
  else
    expect(tags).to include(tag)
  end
end
