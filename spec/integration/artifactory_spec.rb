require 'spec_helper'

# This integration test uses some environment variables to configure which
# Artifactory server to talk to, as there is no ArtifactoryZero to test against.
# If those aren't present, we skip the tests.
#
# $TEST_STOVE_ARTIFACTORY - URL to the Chef virtual repository.
# $TEST_STOVE_ARTIFACTORY_REAL - URL to the non-virtual repository.
# $TEST_STOVE_ARTIFACTORY_API_KEY - API key to use.

describe 'artifactory integration test', artifactory_integration: true do
  include RSpecCommand
  let(:upload_url) { ENV['TEST_STOVE_ARTIFACTORY'] }
  let(:delete_url) { ENV['TEST_STOVE_ARTIFACTORY_REAL'] }
  let(:api_key) { ENV['TEST_STOVE_ARTIFACTORY_API_KEY'] }
  around do |ex|
    WebMock.disable!
    request(:delete, "#{delete_url}/stove_integration_test")
    begin
      ex.run
    ensure
      request(:delete, "#{delete_url}/stove_integration_test")
      WebMock.enable!
    end
  end

  def request(method, url)
    uri = URI(url)
    req = Net::HTTP.const_get(method.to_s.capitalize).new(uri)
    req['X-Jfrog-Art-Api'] = api_key
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end
  end

  let(:upload) { JSON.parse(request(:get, "#{upload_url}/api/v1/cookbooks/stove_integration_test/versions/1.0.0").body) }

  describe 'help output' do
    command 'stove --help'
    its(:stdout) { is_expected.to include('--artifactory ').and(include('--artifactory-key ')) }
  end

  describe 'uploading a cookbook' do
    context 'with no key' do
      fixture_file 'integration_cookbook'
      command(nil, allow_error: true) { "stove --no-git --artifactory #{upload_url}" }

      it 'fails to upload' do
        expect(subject.exitstatus).to_not eq 0
        expect(subject.stdout).to match /You did not specify and Artifactory API key/
      end
    end

    context 'with $ARTIFACTORY_API_KEY' do
      before { _environment['ARTIFACTORY_API_KEY'] = api_key }
      fixture_file 'integration_cookbook'
      command { "stove --no-git --artifactory #{upload_url}" }

      it 'uploads the cookbook' do
        expect(subject.stdout).to eq ''
        expect(upload['version']).to eq '1.0.0'
      end
    end

    context 'with --artifactory-key=@key' do
      fixture_file 'integration_cookbook'
      file('key') { api_key }
      command { "stove --no-git --artifactory #{upload_url} --artifactory-key=@key" }

      it 'uploads the cookbook' do
        expect(subject.stdout).to eq ''
        expect(upload['version']).to eq '1.0.0'
      end
    end

    context 'with --artifactory-key=key' do
      fixture_file 'integration_cookbook'
      file('key') { api_key }
      # Using allow_error here so the command isn't shown if things fail.
      command(nil, allow_error: true) { "stove --no-git --artifactory #{upload_url} --artifactory-key=#{api_key}" }

      it 'uploads the cookbook' do
        expect(subject.stdout).to eq ''
        expect(subject.exitstatus).to eq 0
        expect(upload['version']).to eq '1.0.0'
      end
    end

  end
end
