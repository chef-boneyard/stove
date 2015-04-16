require 'spec_helper'

class Stove::Cookbook
  describe Metadata do
    describe '#to_hash' do
      context 'when the extra metadata is not included' do
        it 'does not include the new metadata fields' do
          hash = subject.to_hash(false)
          expect(hash).to_not include('issues_url')
          expect(hash).to_not include('source_url')
        end
      end

      context 'when the extra metadata is included' do
        it 'includes the new metadata fields' do
          hash = subject.to_hash(true)
          expect(hash).to include('issues_url')
          expect(hash).to include('source_url')
        end
      end
    end
  end
end
