require 'lita'
require 'rufus-scheduler'
require 'json'

module Lita
  module Handlers
    def self.scheduler
      @scheduler ||= Rufus::Scheduler.start_new
    end

    class Cron < Handler
      REDIS_KEY = 'cron'

      # Need to initialize previous jobs for redis when starting

      def initialize(robot)
        super
      end

      def self.default_config(_config)
      end

      on :loaded, :load_on_start

      route(
        /^cron\s+new\s(.+)/i,
        :new,
        command: true,
        help: {
          'cron new CRON_EXPRESSION MESSAGE': 'New cron job.'
        }
      )

      route(
        /^cron\s+delete\s(.+)/i,
        :delete,
        command: true,
        help: {
          'cron delete MESSAGE': 'Delete cron job.'
        }
      )

      route(
        /^cron\s+list/i,
        :list,
        command: true,
        help: {
          'cron list': 'List all cron jobs.'
        }
      )

      def load_on_start(_payload)
        jobs = redis.hgetall(REDIS_KEY)
        jobs.each do |k, v|
          j = JSON.parse(v)
          begin
            Lita::Handlers.scheduler.cron j['cron_line'] do |_job|
              target = Source.new(user: j['u_id'], room: j['room'])
              robot.send_messages(target, k)
              log.info "SENDING: #{k} -> #{target}"
            end

            log.info "Created cron job: #{j['cron_line']} #{k}."
          rescue ArgumentError => e
            response.reply "argument error, perhaps the cronline? #{e.message}"
          end
        end
      end

      def new(response)
        log.info "NEW: #{response.matches} from
        #{response.message.source.user.id}
                  in #{response.message.source.room}"
        input = response.matches[0][0].split(' ')
        cron = input[0..4].join(' ')
        message = input[5..input.count - 1].join(' ')

        if redis.hkeys(REDIS_KEY).include?(message)
          response.reply "#{message} already exists, delete first."
        else
          begin
            job = Lita::Handlers.scheduler.cron cron do |_job|
              log.info("SENDING: #{message}")
              response.reply message
            end

            redis.hset(REDIS_KEY, message, {
              cron_line: job.cron_line.original,
              j_id: job.job_id,
              u_id: response.message.source.user.id,
              room: response.message.source.room }.to_json
                      )
            response.reply "New cron job: #{cron} #{message}"
          rescue ArgumentError => e
            response.reply "argument error, perhaps the cronline? #{e.message}"
          end
        end
      end

      def delete(response)
        if redis.hexists(REDIS_KEY, response.matches[0][0])
          job = JSON.parse(redis.hget(REDIS_KEY, response.matches[0][0]))
          log.info "DELETE: #{response.matches[0][0]}"

          Lita::Handlers.scheduler.unschedule(job['j_id'])
          redis.hdel(REDIS_KEY, response.matches[0][0])
          response.reply "Deleted #{response.matches[0][0]}."
        else
          response.reply "#{response.matches[0][0]} isn't an existing cron job."
        end
      end

      def list(response)
        log.info 'LISTing all cron jobs'
        keys = redis.hgetall(REDIS_KEY)
        jobs = Lita::Handlers.scheduler.cron_jobs
        if jobs.empty?
          response.reply 'No cron jobs currently running.'
        else
          keys.each do |k, v|
            j = JSON.parse v
            cron_line = [j['cron_line']]

            response.reply "#{k}=>#{cron_line}"
          end
        end
      end

      private

      def config
        # None yet
        Lita.config.handlers.cron
      end
    end
    Lita.register_handler(Cron)
  end
end
