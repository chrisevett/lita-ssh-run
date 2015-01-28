module Lita
  module Handlers
    class SshRun < Handler
      require 'net/ssh'

      route(/^run(.+)\s+on\s+(.+)/i, :run_ssh, command: true)

      route(/^Username\s+for\s+(.+)\s+is\s+(.+)/i, :set_user, command: true)

      route(/^Password\s+for\s+(.+)\s+is\s+(.+)/i, :set_pass, command: true)

      def run_ssh(response)

        cmd = response.matches[0][0]
        puts response.matches
        server = response.matches[0][1]
        id_server_user = response.user.id + "_" + server + "_user"
        id_server_pass = response.user.id + "_" + server + "_pass"
        usernm = redis.get(id_server_user)
        passwd = redis.get(id_server_pass)

        if usernm && passwd

          Net::SSH.start(server, usernm, :password => passwd) do |ssh|
            output = ssh.exec!(cmd)
            response.reply("```" + output + "```")
          end

        elsif usernm
          get_user_pass(response, server, "Password")
        elsif passwd
          get_user_pass(response, server, "Username")
        else
          get_user_pass(response, server, "Username", "Password")
        end


      end



      def get_user_pass(response, server, *user_pass)
        user_pass.each do |blah|
          response.reply_privately("No #{blah.capitalize} found for you on #{server}\nPlease privately reply with:\n`Lita, #{blah.capitalize} for #{server} is #{blah.upcase}`")
        end

      end


      def set_user(response)
        server = response.matches[0][0]
        usernm = response.matches[0][1]
        id_server_user = response.user.id + "_" + server + "_user"
        redis.set(id_server_user, usernm)
        response.reply_privately("Username set")
      end

      def set_pass(response)
        server = response.matches[0][0]
        passwd= response.matches[0][1]
        id_server_pass = response.user.id + "_" + server + "_pass"
        redis.set(id_server_pass, passwd)
        response.reply_privately("Password set")
      end


    end

    Lita.register_handler(SshRun)
  end
end
