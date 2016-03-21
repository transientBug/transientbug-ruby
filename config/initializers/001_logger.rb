require 'logger'

# Allow us to log to both the console and a log file at the same time...
class MultiIO
  def initialize *targets
     @targets = targets
  end

  def write *args
    @targets.each{ |t| t.write *args }
  end

  def close
    @targets.each &:close
  end
end

FileUtils.mkdir_p AshFrame.root.join('logs')

module AshFrame
  module_function
  def logger
    @@logger_io ||= MultiIO.new(
      File.open(AshFrame.root.join('logs', "git-blog.#{ Time.current.iso8601 }.log"), 'a'),
      STDOUT
    )

    @@logger ||= Logger.new(@@logger_io).tap do |logger|
      # setup our logger for everything...
      if AshFrame.environment == :development
        logger.level = Logger::DEBUG
      else
        logger.level = Logger::INFO
      end
    end
  end
end

