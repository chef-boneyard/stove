require 'spec_helper'

module Stove::Error
  describe StoveError do
    it 'raises an exception with the correct message' do
      expect { raise described_class }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          Oh no! Something really bad happened. I am not sure what actually happened because this is the catch-all error, but you should most definitely report an issue on GitHub at https://github.com/sethvargo/stove.
        EOH
      }
    end
  end

  describe GitFailed do
    it 'raises an exception with the correct message' do
      expect { raise described_class.new(command: 'foo') }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          An error occurred while running:

              git foo

          There is likely an informative message from git that explains what happened right above this message.
        EOH
      }
    end
  end

  describe MetadataNotFound do
    it 'raises an exception with the correct message' do
      expect { raise described_class.new(path: '/path') }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          The file at `/path' does not exist or does not contain valid metadata. Please make sure you have specified the correct path and that the metdata file exists.
        EOH
      }
    end
  end

  describe ServerUnavailable do
    it 'raises an exception with the correct message' do
      expect { raise described_class.new(url: 'http://server') }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          The server at `http://server' is unavailable or is not currently accepting client connections. Please ensure the server is accessible via ping (or telnet) on your local network. If this error persists, please contact your network administrator.
        EOH
      }
    end
  end

  describe CommunityCategoryValidationFailed do
    it 'raises an exception with the correct message' do
      expect { raise described_class }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          You did not specify a category! The Chef community site requires all cookbooks belong to a category. For existing cookboks, Stove can query the Chef community site API and automatically complete the category for you. However, for new cookbooks, you must specify the `--category' flag at runtime:

              stove --category Utilities

          For a complete listing of categories, please see the Chef community site.
        EOH
      }
    end
  end

  describe CommunityKeyValidationFailed do
    it 'raises an exception with the correct message' do
      expect { raise described_class }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          You did not specify the path to a private key! The Chef community site requires a private key for authentication:

              stove --key ~/.chef/sethvargo.pem
        EOH
      }
    end
  end

  describe CommunityUsernameValidationFailed do
    it 'raises an exception with the correct message' do
      expect { raise described_class }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          You did not specify the username to authenticate with! The Chef community site requires a username for authentication:

              stove --username sethvargo
        EOH
      }
    end
  end

  describe GitCleanValidationFailed do
    it 'raises an exception with the correct message' do
      expect { raise described_class.new(path: '/path') }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          The cookbook at `/path' has untracked files! In order to use the git plugin, you must have a clean working directory. Please commit or stash your changes before running Stove again.
        EOH
      }
    end
  end

  describe GitRepositoryValidationFailed do
    it 'raises an exception with the correct message' do
      expect { raise described_class.new(path: '/path') }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          The cookbook at `/path' does not appear to be a valid git repository. In order to use the git plugin, your cookbook must be initialized as a git repository. To create a git repository, run:

              git init /path
        EOH
      }
    end
  end

  describe GitUpToDateValidationFailed do
    it 'raises an exception with the correct message' do
      expect { raise described_class.new(path: '/path') }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          The cookbook at `/path' is out of sync with the remote repository. Please update your local cache with the remote repository before continuing:

              git pull

          And then push your local changes to the remote repository:

              git push
        EOH
      }
    end
  end

  describe GitFailed do
    it 'raises an exception with the correct message' do
      expect { raise described_class.new(command: 'run') }.to raise_error { |error|
        expect(error).to be_a(described_class)
        expect(error.message).to eq <<-EOH.gsub(/^ {10}/, '')
          An error occurred while running:

              git run

          There is likely an informative message from git that explains what happened right above this message.
        EOH
      }
    end
  end
end
