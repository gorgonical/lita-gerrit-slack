module Lita
  module Handlers
    class Cthulhu < Handler
      route /^register me (.+)$/, :register, command: true,
                       help: { "register me EMAIL" => "Registers the user to receive Gerrit notifications by EMAIL." }

      route /^unregister me$/, :unregister, command: true,
                         help: { "unregister me" => "Unregisters the user for Gerrit notifications." }

      def register(response)
        redis.set(user.id, matches.first)
        redis.sadd(users, user.id)
        redis.incr(num_users)
        reply_privately("Registered user #{user.name} to receive Gerrit notifications.")
      end

        def unregister(response)
        redis.del(user.id)
        redis.spop(users, user.id)
        redis.decr(num_users)
        reply_privately("Unregistered user #{user.name} from receiving Gerrit notifications.")
      end

      def fetch_loop
        every(180) do |timer|
          redis.smembers(users).each do |user_id|
            user_name = Lita::User.find_by_id(user_id).name
            user
            # fetch all patches by user email
          end

          timer.stop if redis.get(num_users) == 0
        end
      end

      Lita.register_handler(self)
    end
  end
end
