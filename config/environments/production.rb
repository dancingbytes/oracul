options[:user]  = 'tyralion'
self.port       = 8080
logger.level    = Log4r::ERROR

config['mongo'] = EventMachine::Synchrony::ConnectionPool.new(size: 20) do
  
  conn = EM::Mongo::Connection.new('localhost', 27017, 1, {:reconnect_in => 1})
  conn.db('oracul')

end