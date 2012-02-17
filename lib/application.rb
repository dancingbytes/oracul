# encoding: utf-8
module Oracul

  class Application

    class << self

      def initialize!
        
        options_parser.parse!(ARGV)
        if @options[:start]
          start
        elsif @options[:stop]
          stop
        end  

      end # initialize!

      private

      def start

        if running?(get_pid)
          puts "Already running"
        else

          init_connection
          init_goliath

          res = false

          10.times {
            if running?(get_pid)
              res = true
              break
            else  
              sleep(1)
            end  
          }


          if res
            puts "Process [pid #{get_pid}] was successfully started."
          else
            code = $!.is_a?(::SystemExit) ? $!.status : 1
            puts "Process failure with code #{code}."
          end  

        end  

      end # start

      def stop

        if running?(get_pid)

          ::File.unlink(::Oracul.pid_file) if stop_process(get_pid)

          if $!.nil? || $!.is_a?(::SystemExit) && $!.success?
            puts "Process successfully stopped."
          else
            code = $!.is_a?(::SystemExit) ? $!.status : 1
            puts "Process failure with code #{code}."
          end

        else
          puts "Not running"
        end  

      end # stop

      def options_parser

        @options ||= {
          :env => :production
        }
        @options_parser ||= ::OptionParser.new do |opts|

          opts.banner = "Usage: oracul [options]"

          opts.separator ""
          opts.separator "Server options:"

          opts.on('-r', '--start', "Start program") { |val| @options[:start] = val }
          opts.on('-s', '--stop',  "Stop program") { |val| @options[:stop] = val }
          opts.on('-e', '--environment NAME', "Set the execution environment (prod, dev or test) (default: #{@options[:env]})") { |val| @options[:env] = val }
          opts.on('-h', '--help',  'Display help message') { puts opts; exit }

          opts.separator ""

        end

      end # options_parser

      def get_pid
        
        return unless ::File.exists?(::Oracul.pid_file)
        @pid ||= ::IO.read(::Oracul.pid_file).to_i

      end # get_pid 

      def running?(pid = get_pid)

        return false if pid.nil?

        begin
          ::Process.kill(0, pid)
          return true
        rescue
          return false
        end

      end # running?

      def stop_process(pid, sig = 'QUIT')

        return false if pid.nil? || @stoping
        @stoping = true

        begin
          ::Process.kill(sig, pid)
        rescue ::Errno::ESRCH
          @stoping = false
          return true
        end

        begin

          5.times {

            if running?(pid)
              sleep(1)
              ::Process.kill('KILL', @pid)
            end

          }

          if running?(pid)
            ::STDOUT.puts "Unable to forcefully kill process with pid #{pid}."
            ::STDOUT.flush
            return false
          else
            return true
          end  

        rescue ::Errno::ESRCH
          return true
        rescue => e
          return false
        ensure
          @pid = nil
          @stoping = false
        end

      end # stop_process

      def init_connection
      end # init_connection  

      def init_goliath

        runner = ::Goliath::Runner.new([], nil)
        ::Goliath.env = @options[:env]
        runner.log_file = ::Oracul.log_file
        runner.pid_file = ::Oracul.pid_file
        runner.daemonize = true
        runner.api = ::Oracul::Routes.new
        runner.app = ::Goliath::Rack::Builder.build(::Oracul::Routes, runner.api)
        runner.run("oracul")

      end # init_goliath

    end # class << self

  end # Application

end # Oracul  