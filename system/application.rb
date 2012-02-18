# encoding: utf-8
module Oracul

  class Application

    class << self

      def initialize!
        
        options_parser.parse!(ARGV)

        return start    if @options[:start] == true          
        return stop     if @options[:stop]  == true
        return restart  if @options[:restart]  == true
        return console  if @options[:console]  == true

        puts options_parser.help

      end # initialize!

      private

      def start(quiet = false)

        if running?(get_pid)
          puts "Already running" unless quiet
          return true
        end  
        
        ::Oracul::Server.start(@options[:env])

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
        res

      end # start

      def stop(quiet = false)

        unless running?(get_pid)
          puts "Not running" unless quiet
          return true
        end  

        ::File.unlink(::Oracul.pid_file) if stop_process(get_pid)

        if $!.nil? || $!.is_a?(::SystemExit) && $!.success?
          puts "Process successfully stopped."
          return true
        else
          code = $!.is_a?(::SystemExit) ? $!.status : 1
          puts "Process failure with code #{code}."
          return false
        end

      end # stop

      def restart
        start if stop(true)
      end # restart  

      def console
        ::Oracul::Console.start(@options[:env])
      end # console

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
          opts.on('--restart',  "Restart program") { |val| @options[:restart] = val }
          opts.on('-c', '--console',  "Start console") { |val| @options[:console] = val }
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

    end # class << self

  end # Application

end # Oracul  