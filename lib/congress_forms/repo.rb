require "tmpdir"
require "fileutils"

module CongressForms
  class Repo
    attr_reader :remote
    attr_accessor :auto_update

    alias :auto_update? :auto_update

    def initialize(remote)
      @remote = remote
      self.auto_update = true
    end

    def location
      @location ||= Pathname.new(Dir.mktmpdir).tap do |tmpdir|
        Kernel.at_exit{ FileUtils.rm_r(tmpdir) }
      end
    end

    def location=(loc)
      @location = loc ? Pathname.new(loc) : nil
    end

    def clone
      system(
        "git",
        "clone",
        "--quiet",
        "--depth", "1",
        remote,
        location.to_s
      ) or raise Error, "Error cloning repo at #{remote}"
    end

    def initialized?
      File.exists?(location.join(".git"))
    end

    def update!
      system(
        "git",
        "--git-dir", location.join(".git").to_s,
        "pull",
        "--quiet",
        "--ff-only"
      ) or raise Error, "Error updating git repo at #{location}"
    end

    def update
      begin
        update!
      rescue
      end
    end

    def age
      repo_touched_at = File.mtime(location.join(".git", "HEAD"))
      Time.now - repo_touched_at
    end

    def find(file)
      clone unless initialized?
      update if auto_update? && age > 5*60 # update every 5m
      location.join(file).to_s
    end
  end
end
