honeybadger_config = Honeybadger::Config.new env: AshFrame.environment.to_s
Honeybadger.start honeybadger_config
