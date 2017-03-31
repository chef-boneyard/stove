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
          expect(hash['gems']).to eq([['rspec']])
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
          expect(hash['gems']).to eq([['rspec']])
          expect(hash).not_to include('source_url')
          expect(hash).not_to include('issues_url')
        end
      end
    end

    describe '#chef_version' do
      let(:hash_version) { subject.to_hash(true)['chef_version'] }

      context 'with no chef_version line' do
        it 'returns []' do
          expect(subject.chef_version).to eq []
          expect(hash_version).to eq []
        end
      end

      context 'with a single chef_version requirement' do
        it 'returns [[req]]' do
          subject.chef_version('>= 12.0')
          expect(subject.chef_version).to eq [['>= 12.0']]
          expect(hash_version).to eq [['>= 12.0']]
        end
      end

      context 'with a multi-part chef_version requirement' do
        it 'returns [[req1, req2]]' do
          subject.chef_version('>= 12.0', '< 14.0')
          expect(subject.chef_version).to eq [['>= 12.0', '< 14.0']]
          expect(hash_version).to eq [['< 14.0', '>= 12.0',]]
        end
      end

      context 'with multiple chef_version requirements' do
        it 'returns [[req1], [req2]]' do
          subject.chef_version('< 12')
          subject.chef_version('> 14')
          expect(subject.chef_version).to eq [['< 12'], ['> 14']]
          expect(hash_version).to eq [['< 12'], ['> 14']]
        end
      end
    end

    describe '#ohai_version' do
      let(:hash_version) { subject.to_hash(true)['ohai_version'] }

      context 'with no ohai_version line' do
        it 'returns []' do
          expect(subject.ohai_version).to eq []
          expect(hash_version).to eq []
        end
      end

      context 'with a single ohai_version requirement' do
        it 'returns [[req]]' do
          subject.ohai_version('>= 12.0')
          expect(subject.ohai_version).to eq [['>= 12.0']]
          expect(hash_version).to eq [['>= 12.0']]
        end
      end

      context 'with a multi-part ohai_version requirement' do
        it 'returns [[req1, req2]]' do
          subject.ohai_version('>= 12.0', '< 14.0')
          expect(subject.ohai_version).to eq [['>= 12.0', '< 14.0']]
          expect(hash_version).to eq [['< 14.0', '>= 12.0',]]
        end
      end

      context 'with multiple ohai_version requirements' do
        it 'returns [[req1], [req2]]' do
          subject.ohai_version('< 12')
          subject.ohai_version('> 14')
          expect(subject.ohai_version).to eq [['< 12'], ['> 14']]
          expect(hash_version).to eq [['< 12'], ['> 14']]
        end
      end
    end

    describe '#gem' do
      let(:hash_gems) { subject.to_hash(true)['gems'] }

      context 'with no gem line' do
        it 'returns []' do
          expect(subject.gems).to eq []
          expect(hash_gems).to be_nil
        end
      end

      context 'with a single gem dependency' do
        it 'returns [[gem]]' do
          subject.gem('nokogiri')
          expect(subject.gems).to eq [['nokogiri']]
          expect(hash_gems).to eq [['nokogiri']]
        end
      end

      context 'with a gem dependency with a version specifier' do
        it 'returns [[gem, ver]]' do
          subject.gem('nokogiri', '>= 1.2.3')
          expect(subject.gems).to eq [['nokogiri', '>= 1.2.3']]
          expect(hash_gems).to eq [['nokogiri', '>= 1.2.3']]
        end
      end

      context 'with multiple gem dependencies' do
        it 'returns [[gem1], [gem2]]' do
          subject.gem('nokogiri')
          subject.gem('rack')
          expect(subject.gems).to eq [['nokogiri'], ['rack']]
          expect(hash_gems).to eq [['nokogiri'], ['rack']]
        end
      end
    end

  end
end
