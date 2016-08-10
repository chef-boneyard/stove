require 'spec_helper'

class Stove::Cookbook
  describe Metadata do
    describe '#to_hash' do
      context 'when the extra metadata is not included' do
        it 'does not include the new metadata fields' do
          hash = subject.to_hash(false)
          expect(hash).to_not include('issues_url')
          expect(hash).to_not include('source_url')
          expect(hash).to_not include('chef')
        end
      end

      context 'when the extra metadata is included' do
        it 'includes the new metadata fields' do
          subject.source_url('http://foo.example.com')
          subject.issues_url('http://bar.example.com')
          subject.gem('rspec')
          hash = subject.to_hash(true)
          expect(hash).to include('issues_url')
          expect(hash['source_url']).to eq 'http://foo.example.com'
          expect(hash).to include('source_url')
          expect(hash['issues_url']).to eq 'http://bar.example.com'
          expect(hash).to include('gems')
          expect(hash['gems']).to include('rspec' => '>= 0.0.0')
        end
      end

      context 'when the extra metadata is not defined' do
        it 'does not include the new metadata fields' do
          hash = subject.to_hash(true)
          expect(hash).not_to include('source_url')
          expect(hash).not_to include('issues_url')
          expect(hash).not_to include('gems')
        end
      end

      context 'when only some of the extra metadata is defined' do
        it 'only includes the source_url if issues_url is empty' do
          subject.source_url('http://foo.example.com')
          hash = subject.to_hash(true)
          expect(hash).to include('source_url')
          expect(hash['source_url']).to eq 'http://foo.example.com'
          expect(hash).not_to include('issues_url')
        end

        it 'only includes the issues_url if source_url is empty' do
          subject.issues_url('http://bar.example.com')
          hash = subject.to_hash(true)
          expect(hash).to include('issues_url')
          expect(hash['issues_url']).to eq 'http://bar.example.com'
          expect(hash).not_to include('source_url')
        end

        it 'only includes the gems' do
          subject.gem('rspec')
          hash = subject.to_hash(true)
          expect(hash).to include('gems')
          expect(hash['gems']).to include('rspec' => '>= 0.0.0')
          expect(hash).not_to include('source_url')
          expect(hash).not_to include('issues_url')
        end
      end
    end
  end
end
