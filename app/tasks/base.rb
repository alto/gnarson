module Tasks
  class Base
    cattr_accessor :logger

  protected

    def self.mark(state)
      log "#{identifier} #{state}"
    end

    def self.log(line, log_level=:info)
      # self.logger ||= (Rails.env.test? ? Rails.logger : Logger.new(STDOUT))
      # self.logger.send(log_level, "#{Time.now}: #{line}")
      Rails.logger = Logger.new(STDOUT) if !Rails.env.test?
      # Rails.logger.send(log_level, "#{Time.now}: #{line}")
      Rails.logger.send(log_level, line)
    end

    def self.process(&block)
      # _process(__method__, &block)
      _process(block.binding.eval('__method__'), &block)
    rescue => exc
      log("Error while executing #{identifier}: #{exc.message}", :error)
      log("Backtrace:", :error)
      log(exc.backtrace.join("\n"), :error)
      raise
    end

    def self._process(method)
      @method = method
      mark 'started'
      yield if block_given?
      ExceptionRecorder.play(identifier) if @exception_recorded
      mark 'finished'
    end

    def self.identifier
      "#{self}::#{@method}"
    end
  end
end
