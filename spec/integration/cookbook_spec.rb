require 'spec_helper'

module Stove
  describe Cookbook do
    describe '#tarball' do
      let(:path) { generate_cookbook('basic', 'basic-cookbook') }
      it 'contains a directory with the same name as the cookbook' do
        tarball = Cookbook.new(path).tarball

        structure = []

        Zlib::GzipReader.open(tarball.path) do |gzip|
          Gem::Package::TarReader.new(gzip) do |tar|
            structure = tar.map(&:full_name).sort
          end
        end

        expect(structure).to eq(%w(
          basic/.foodcritic
          basic/CHANGELOG.md
          basic/README.md
          basic/attributes/default.rb
          basic/attributes/system.rb
          basic/definitions/web_app.rb
          basic/files/default
          basic/files/default/.authorized_keys
          basic/files/default/example.txt
          basic/files/default/patch.txt
          basic/libraries/magic.rb
          basic/metadata.json
          basic/providers/thing.rb
          basic/recipes/default.rb
          basic/recipes/system.rb
          basic/resources/thing.rb
          basic/templates/default
          basic/templates/default/.env.erb
          basic/templates/default/another.text.erb
          basic/templates/default/example.erb
        ))
      end
    end
  end
end
