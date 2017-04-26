require 'spec_helper'

# Can't use a double() for this because of the late-binding way StoveError
# renders the Erb content, which is after the example ends.
FakeCookbook = Struct.new(:name, :version)

describe Stove::Artifactory do
  before { Stove::Config.ssl_verify = true }

  describe '.upload' do
    let(:cookbook) { FakeCookbook.new('testcook', '1.2.3') }
    subject { described_class.upload(cookbook) }
    before do
      # Default configuration for the test.
      Stove::Config.artifactory = 'https://artifactory.example/api/chef/chef'
      Stove::Config.artifactory_key = 'secret'
      # cookbook.tarball() stub.
      allow(cookbook).to receive(:tarball) {|ext| StringIO.new(ext ? 'extended' : 'simple') }
    end

    context 'with defaults' do
      it 'uploads the file' do
        stub_request(:get, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook/versions/1.2.3').with(headers: {'X-Jfrog-Art-Api' => 'secret'}).to_return(body: '')
        stub_request(:post, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook.tgz').with(headers: {'X-Jfrog-Art-Api' => 'secret'}, body: 'simple').to_return(status: 201)
        expect { subject }.to_not raise_error
      end
    end

    context 'with a 404 for an unknown cookbook' do
      # This is how real Supermarket returns a non-existent cookbook so make sure it works with that too.
      it 'uploads the file' do
        stub_request(:get, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook/versions/1.2.3').with(headers: {'X-Jfrog-Art-Api' => 'secret'}).to_return(status: 404, body: '{some json error}')
        stub_request(:post, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook.tgz').with(headers: {'X-Jfrog-Art-Api' => 'secret'}, body: 'simple').to_return(status: 201)
        expect { subject }.to_not raise_error
      end
    end

    context 'with extended_metadata = true' do
      subject { described_class.upload(cookbook, true) }
      it 'uploads with extended metadata' do
        stub_request(:get, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook/versions/1.2.3').with(headers: {'X-Jfrog-Art-Api' => 'secret'}).to_return(body: '')
        stub_request(:post, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook.tgz').with(headers: {'X-Jfrog-Art-Api' => 'secret'}, body: 'extended').to_return(status: 201)
        expect { subject }.to_not raise_error
      end
    end

    context 'with a colliding upload' do
      it 'should raise an exception' do
        stub_request(:get, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook/versions/1.2.3').with(headers: {'X-Jfrog-Art-Api' => 'secret'}).to_return(body: '{some json}')
        expect { subject }.to raise_error Stove::Error::CookbookAlreadyExists
      end
    end

    context 'with a failed upload' do
      it 'uploads the file' do
        stub_request(:get, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook/versions/1.2.3').with(headers: {'X-Jfrog-Art-Api' => 'secret'}).to_return(body: '')
        stub_request(:post, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook.tgz').with(headers: {'X-Jfrog-Art-Api' => 'secret'}, body: 'simple').to_return(status: 500)
        expect { subject }.to raise_error Net::HTTPFatalError
      end
    end

    context 'with a newline in the API key' do
      before { Stove::Config.artifactory_key = "secret\n" }
      it 'uploads the file' do
        stub_request(:get, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook/versions/1.2.3').with(headers: {'X-Jfrog-Art-Api' => 'secret'}).to_return(body: '')
        stub_request(:post, 'https://artifactory.example/api/chef/chef/api/v1/cookbooks/testcook.tgz').with(headers: {'X-Jfrog-Art-Api' => 'secret'}, body: 'simple').to_return(status: 201)
        expect { subject }.to_not raise_error
      end
    end

  end

  # Break encapsulation a bit to test the ssl_verify configuration.
  describe '#connection' do
    let(:url) { 'https://artifactory.example/api/chef/chef' }
    let(:http) { double('Net::HTTP') }
    # Make sure we don't use the singleton instance so this stub HTTP object
    # doesn't get cached on it.
    subject { described_class.send(:new).send(:connection) }
    before do
      allow(http).to receive(:start).and_return(http)
      Stove::Config.artifactory = url
    end

    context 'with an HTTPS URI' do
      it 'enables TLS' do
        expect(Net::HTTP).to receive(:new).with('artifactory.example', 443).and_return(http)
        expect(http).to receive(:use_ssl=).with(true)
        expect(subject).to eq http
      end
    end

    context 'with an HTTP URI' do
      let(:url) { 'http://artifactory.example/api/chef/chef' }
      it 'does not enable TLS' do
        expect(Net::HTTP).to receive(:new).with('artifactory.example', 80).and_return(http)
        expect(http).to_not receive(:use_ssl=)
        expect(subject).to eq http
      end
    end

    context 'with Config.ssl_verify = false' do
      before { Stove::Config.ssl_verify = false }
      it 'sets verify mode VERIFY_NONE' do
        expect(Net::HTTP).to receive(:new).with('artifactory.example', 443).and_return(http)
        expect(http).to receive(:use_ssl=).with(true)
        expect(http).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
        expect(subject).to eq http
      end
    end

    context 'with $STOVE_NO_SSL_VERIFY' do
      around do |ex|
        old_value = ENV['STOVE_NO_SSL_VERIFY']
        ENV['STOVE_NO_SSL_VERIFY'] = 'true'
        begin
          ex.run
        ensure
          ENV['STOVE_NO_SSL_VERIFY'] = old_value
        end
      end
      it 'sets verify mode VERIFY_NONE' do
        expect(Net::HTTP).to receive(:new).with('artifactory.example', 443).and_return(http)
        expect(http).to receive(:use_ssl=).with(true)
        expect(http).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
        expect(subject).to eq http
      end
    end

  end
end
