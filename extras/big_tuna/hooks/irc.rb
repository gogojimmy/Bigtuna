module BigTuna
  class Hooks::Irc < Hooks::Base
    NAME = "irc"

    def build_passed(build, config)
      project = build.project
      Delayed::Job.enqueue(Job.new(config, "Build '#{build.display_name}' in '#{project.name}' PASSED (#{build_url(build)})"))
    end

    def build_fixed(build, config)
      project = build.project
      Delayed::Job.enqueue(Job.new(config, "Build '#{build.display_name}' in '#{project.name}' FIXED (#{build_url(build)})"))
    end

    def build_still_fails(build, config)
      project = build.project
      Delayed::Job.enqueue(Job.new(config, "Build '#{build.display_name}' in '#{project.name}' STILL FAILS (#{build_url(build)})"))
    end

    def build_failed(build, config)
      project = build.project
      Delayed::Job.enqueue(Job.new(config, "Build '#{build.display_name}' in '#{project.name}' FAILED (#{build_url(build)})"))
    end

    class Job
      def initialize(config, message)
        @config = config
        @message = message
      end

      def perform
        uri = "irc://#{@config[:user_name]}"
        uri += ":#{@config[:room_password]}" if @config[:room_password].present?
        uri += "@#{@config[:server]}:#{@config[:port].present? ? '6667' : @config[:port]}"
        uri += "/#{@config[:room]}"
        ShoutBot.shout(uri) { |channel| channel.say @message }
      end
    end
  end
end
