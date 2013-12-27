module Stove
  class Action::Changelog < Action::Base
    id 'changelog'
    description 'Generate and prompt for a CHANGELOG'

    validate(:exists) do
      File.exists?('CHANGELOG.md')
    end

    validate(:format) do
      lines = File.read('CHANGELOG.md')
      lines.match(/^[\w\s]+\n=+(.*\n)+v[0-9\.]+(\ \(.+\))?\n\-+/)
    end

    validate(:editor) do
      !ENV['EDITOR'].nil?
    end

    def run
      log.info('Generating new Changelog')
      log.debug("Generated changeset:\n#{default_changeset}")

      # Open a file prompt for changes
      prompt_for_changeset

      log.debug("New changeset:\n#{cookbook.changeset}")

      # Write the new changelog to disk
      path     = File.join(cookbook.path, 'CHANGELOG.md')
      contents = File.readlines(path)
      index    = contents.find_index { |line| line =~ /^(--)+/ }

      log.debug("Writing changelog at `#{path}', index #{index}")

      contents.insert(index - 2, "\n" + cookbook.changeset + "\n\n")

      File.open(path, 'w') { |file| file.write(contents.join('')) }
    end

    def prompt_for_changeset
      tempfile = Tempfile.new(["#{cookbook.name}-changeset-#{Time.now}", '.md'])
      tempfile.write(default_changeset)
      tempfile.rewind

      # Shell out to the default editor
      system %Q|$EDITOR "#{tempfile.path}"|

      # Save the resulting changes back to the cookbook object
      cookbook.changeset = File.read(tempfile.path).strip

      # Cleanup
      tempfile.close
      tempfile.unlink
    end

    def default_changeset
      return @default_changeset if @default_changeset

      header = "v#{cookbook.version} (#{Time.now.to_date})"

      contents = []
      contents << header
      contents << '-'*header.length
      contents << cookbook.changeset || 'Enter CHANGELOG entries here'
      contents << ''

      @default_changeset = contents.join("\n")
      @default_changeset
    end
  end
end
