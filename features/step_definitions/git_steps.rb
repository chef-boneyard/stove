Given /^the remote repository has additional commits/ do
  cmd = [
    'cd "' + fake_git_remote + '"',
    'touch myfile.txt',
    'git add --force myfile.txt',
    'git commit --message "Add new file"',
  ].join(' && ')

  %x|#{cmd}|
end

Then /^the git remote should( not)? have the commit "(.+)"$/ do |negate, message|
  commits = git_commits(fake_git_remote)

  if negate
    expect(commits).to_not include(message)
  else
    expect(commits).to include(message)
  end
end

Then /^the git remote should( not)? have the tag "(.+)"$/ do |negate, tag|
  tags = git_tags(fake_git_remote)

  if negate
    expect(tags).to_not include(tag)
  else
    expect(tags).to include(tag)
  end
end
