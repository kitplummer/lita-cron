require "lita"
require "rufus-scheduler"

module Lita
  module Handlers
    class Cron < Handler
      REDIS_KEY = "cron"

      # Need to initialize previous jobs for redis when starting

      def initialize(robot)
        @@scheduler = Rufus::Scheduler.start_new
        super
      end

      def self.default_config(config)
      end

      route(/^cron\s+new\s(.+)/i, :new, command: true, help: {
        "cron new CRON_EXPRESSION MESSAGE" => "New cron job."
      })

      route(/^cron\s+delete\s(.+)/i, :delete, command: true, help: {
        "cron delete MESSAGE" => "Delete cron job."
      })

      route(/^cron\s+list/i, :list, command: true, help: {
        "cron list" => "List all cron jobs."
      })

      def new(response)
        log.info "NEW: #{response.matches}"
        input = response.matches[0][0].split(" ")
        cron = input[0..4].join(" ")
        message = input[5..input.count()-1].join(" ")

        if(redis.hkeys(REDIS_KEY).include?(message))
          response.reply "#{message} already exists, delete first."
        else
          begin
            job = @@scheduler.cron cron do |job|
                response.reply(message)
            end

            redis.hset(REDIS_KEY, message, job.job_id)
            response.reply("New cron job: #{cron} - #{message}")
          rescue ArgumentError => e
            response.reply "argument error, perhaps the cronline? #{e.message}"
          end
        end
      end

      def delete(response)
        log.info "DELETE: #{response.matches}"
        if redis.hexists(REDIS_KEY, response.matches[0][0])
          job_id = redis.hget(REDIS_KEY, response.matches[0][0])
          @@scheduler.unschedule(job_id)
          redis.hdel(REDIS_KEY, response.matches[0][0]) >= 1
          response.reply("Deleted #{response.matches[0][0]}.")
        else
          response.reply("#{key} isn't stored.")
        end
      end

      def list(response)
        keys = redis.hkeys(REDIS_KEY)

        if keys.empty?
          response.reply("No keys are stored.")
        else
          response.reply(keys.sort.join(", "))
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
