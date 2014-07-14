require 'git_init/version'
require 'pathname'
require 'fileutils'


module GitInit
  class GitUrl

    attr_accessor :domain, :path, :user, :type, :basename, :proto

    def initialize(opts={})

      # convert url if needed
      if opts.is_a?(String)
        opts = GitUrl.parse_url(opts)
      end

      # set instance vars
      opts.each do |key, value|
        self.send("#{key}=".to_sym, value)
      end
    end

    def url
      if type == :http
        "#{self.proto}://#{self.domain}/#{File.join(self.path,self.basename)}"
      elsif type == :ssh
        if self.user.nil?
          user = ""
        else
          user = "#{self.user}@"
        end
        "#{user}#{self.domain}:#{File.join(self.path,self.basename)}"
      elsif type == :git
        "git://#{self.domain}/#{File.join(self.path,self.basename)}"
      end
    end


    def GitUrl.parse_url(url)

      ret_val = {}

      # Detect type
      ret_val[:type] = detect_type(url)

      # Parse ssh url
      if ret_val[:type] == :ssh
        m = /^(([^@]+)@)?([^:]+):(.*\.git$)/.match(url)
        ret_val[:user] = m[2]
        ret_val[:domain] = m[3]
        ret_val[:path] = File.dirname(m[4])
        ret_val[:basename] = File.basename(m[4])
      elsif ret_val[:type] == :http
        m = /^(https?):\/\/([^\/]+)\/(.*\.git$)/.match(url)
        ret_val[:proto] = m[1]
        ret_val[:domain] = m[2]
        ret_val[:path] = File.dirname(m[3])
        ret_val[:basename] = File.basename(m[3])
      elsif ret_val[:type] == :git
        m = /^git:\/\/([^\/]+)\/(.*\.git$)/.match(url)
        ret_val[:domain] = m[1]
        ret_val[:path] = File.dirname(m[2])
        ret_val[:basename] = File.basename(m[2])
      end


      return ret_val

    end

    def GitUrl.detect_type(url)

      # Simple git url
      return :git if (/^git:\/\//.match(url))

      # http(s)
      return :http if (/^https?:\/\//.match(url))

      # ssh
      return :ssh if (/:/.match(url))

      raise "Unknown type of url #{url}"

    end


  end


  def GitInit.run
    unless ARGV[0]
      $stderr.puts "Please give a git url as first parameter"
      exit 1
    end
    git=GitUrl.new (ARGV[0])
    dest_path = Pathname.new(ENV['HOME']).join('git', git.domain, git.path, git.basename[0..-5])

    if File.exists? dest_path
      $stderr.puts "Destination directory already exists: '#{dest_path}'"
      exit 2
    end

    FileUtils.mkdir_p dest_path.dirname

    system('git', 'clone', git.url, dest_path.to_s)
    puts dest_path

  end

end
