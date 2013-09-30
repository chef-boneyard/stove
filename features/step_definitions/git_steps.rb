Given /^the remote repository has additional commits/ do
  Dir.chdir(fake_git_remote) do
    shellout 'touch myfile.txt'
    git 'add myfile.txt'
    git 'commit -m "Add a new file"'
  end
end

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
