require 'tempfile'

module Stove
  module Git
    # Run a git command.
    #
    # @param [String] command
    #   the command to run
    #
    # @return [String]
    #   the stdout from the command
    def git(command)
      Stove::Logger.debug "shellout 'git #{command}'"
      response = shellout("git #{command}")

      Stove::Logger.debug response.stdout

      unless response.success?
        Stove::Logger.debug response.stderr
        raise Stove::GitError, response.stderr
      end

      response.stdout.strip
    end

    # Return true if the current working directory is a valid
    # git repot, false otherwise.
    #
    # @return [Boolean]
    def git_repo?
      git('rev-parse --show-toplevel')
      true
    rescue
      false
    end

    # Return true if the current working directory is clean,
    #  false otherwise
    #
    # @return [Boolean]
    def git_repo_clean?
      !!git('status -s').strip.empty?
    rescue
      false
    end

    def shellout(command)
      out, err = Tempfile.new('shellout.stdout'), Tempfile.new('shellout.stderr')

      begin
        pid = Process.spawn(command, out: out.to_i, err: err.to_i)
        pid, status = Process.waitpid2(pid)

        # Check if we're getting back a process status because win32-process 6.x was a fucking MURDERER.
        # https://github.com/djberg96/win32-process/blob/master/lib/win32/process.rb#L494-L519
        exitstatus  = status.is_a?(Process::Status) ? status.exitstatus : status
      rescue Errno::ENOENT => e
        err.write('')
        err.write('Command not found: ' + command)
      end

      out.close
      err.close

      OpenStruct.new({
        exitstatus: exitstatus,
        stdout: File.read(out).strip,
        stderr: File.read(err).strip,
        success?: exitstatus == 0,
        error?: exitstatus == 0,
      })
    end
  end
end
