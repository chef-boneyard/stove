Given /^the remote repository has additional commits/ do
  cmd = [
    'cd "' + fake_git_remote + '"',
    'touch myfile.txt',
    'git add --force myfile.txt',
    'git commit --message "Add new file"',
  ].join(' && ')

  %x|#{cmd}|
end

Given /^a GPG key exists/ do
  gpg_home = File.join(scratch_dir, '.gnupg')
  set_env('GNUPGHOME', gpg_home)
  Dir.mkdir(gpg_home)
  File.chmod(0700, gpg_home)
  batch_path = File.join(gpg_home, 'batch')
  File.write(batch_path, <<-EOH)
%pubring #{File.join(gpg_home, 'keyring')}
%secring #{File.join(gpg_home, 'keyring.sec')}
Key-Type: DSA
Key-Length: 832
Subkey-Type: ELG-E
Subkey-Length: 800
Name-Real: Alan Smithee
Name-Email: asmithee@example.com
Expire-Date: 0
%commit
EOH
  gpg_wrapper = File.join(gpg_home, 'gpg_wrapper')
  File.write(gpg_wrapper, <<-EOH)
#!/bin/sh
gpg "--keyring=#{File.join(gpg_home, 'keyring')}" "--secret-keyring=#{File.join(gpg_home, 'keyring.sec')}" "$@"
EOH
  File.chmod(0755, gpg_wrapper)

  cmd = [
    "cd \"#{current_dir}\"",
    "git config gpg.program #{gpg_wrapper}",
    'git config user.signingkey asmithee@example.com',
    "gpg --quiet --batch --gen-key #{batch_path}",
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

Then /^the git remote should( not)? have the( signed)? tag "(.+)"$/ do |negate, signed, tag|
  tags = git_tags(fake_git_remote)

  if negate
    expect(tags).to_not include(tag)
  else
    expect(tags).to include(tag)
    expect(git_tag_signature?(fake_git_remote, tag)).to be_truthy if signed
  end
end
