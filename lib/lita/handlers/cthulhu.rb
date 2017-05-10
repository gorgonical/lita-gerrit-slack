module Lita
  module Handlers
    class Cthulhu < Handler
      route /^register me (.+)$/, :register, command: true,
                       help: { "register me EMAIL" => "Registers the user to receive Gerrit notifications by EMAIL." }

      route /^unregister me$/, :unregister, command: true,
                         help: { "unregister me" => "Unregisters the user for Gerrit notifications." }

      def register(response)
        # extract email and store for later
        redis.set(user.email, matches.first)
        redis.sadd(users, user.id)
        redis.incr(num_users)
        response = Faraday.get 'https://gerrit.named-data.net/accounts/email:#{matches.first}'
        # Fetch user gerrit account ID so that we know what changes belong to who
        redis.set(user.gerrit_id,
                  JSON.parse(response.body.lines.drop(1).join)[0]["_account_id"])
        reply_privately("Registered user #{user.name} to receive Gerrit notifications.")
      end

      def unregister(response)
        redis.del(user.id)
        redis.spop(users, user.id)
        redis.decr(num_users)
        reply_privately("Unregistered user #{user.name} from receiving Gerrit notifications.")
        # check all events to see if any events are no longer needed
      end

      def fetch_loop
        every(180) do |timer|
          changes = 
          redis.smembers(users).each do |user_id|
            user_name = Lita::User.find_by_id(user_id).name
            user_email = redis.get(user.id)
            owner_changes = Faraday.get 'https://gerrit.named-data.net/changes/?q=status:open+owner:#{user_email}'
            owner_changes = JSON.parse(changes.body.lines.drop(1).join)
            reviewer_changes = Faraday.get 'https://gerrit.named-data.net/changes/?q=status:open+reviewer:#{user_email}'
            reviewer_changes = JSON.parse(changes.body.lines.drop(1).join)

            
            
            process_owner_changes(owner_changes)
            process_reviewer_changes(reviewer_changes)
          end

          timer.stop if redis.get(num_users) == 0
        end
      end

      def process_owner_changes(owner_changes)
        
      end

      Lita.register_handler(self)
    end
  end
end
