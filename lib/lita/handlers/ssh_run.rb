module Lita
  module Handlers
    class SshRun < Handler
      require 'net/ssh'

      route(/^run\s+(.+)\s+on\s+(.+)/i, :run_ssh, command: true)

      route(/^set\s+(username|password)\s+for\s+(.+)\s+to\s+(.+)/i, :set_user_pass, command: true)

      route(/^set\s+(port)\s+for\s+(.+)\s+to\s+(.+)/i, :set_server_port, command: true)
      
      route(/^clear\s+all\s+stored\s+(creds|credentials)/i, :flush_redis, command: true, restrict_to: :admins)

      def run_ssh(response)

        cmd = response.matches[0][0]
        server = response.matches[0][1]
        id_server_port = response.user.id + "_" + server + "_port"
        port = redis.get(id_server_port)
        if(port.nil?)
          port = 22
        end
        id_server_user = response.user.id + "_" + server + "_username"
        id_server_pass = response.user.id + "_" + server + "_password"
        usernm = redis.get(id_server_user)
        passwd = redis.get(id_server_pass)
        get_user_pass(response, server, "Username") unless usernm
        get_user_pass(response, server, "Password") unless passwd
        
        if usernm && passwd && port
          Net::SSH.start(server, usernm, :port => port, :password => passwd, :timeout => 10) do |ssh|
            output = ssh.exec!(cmd)
            if !output
              response.reply("Command was run, but it appears there was no output to stdout or stderr.")
            else
              response.reply("```" + output.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_') + "```")
            end
          end
        elsif usernm
          response.reply_with_mention("I was unable to find a password for you on #{server}, please check you direct messages from me.")
        elsif passwd
          response.reply_with_mention("I was unable to find a username for you on #{server}, please check you direct messages from me.")
        else
          response.reply_with_mention("I was unable to find a username or password for you on #{server}, please check you direct messages from me.")
        end

      end

      def get_user_pass(response, server, *user_pass)
        user_pass.each do |blah|
          response.reply_privately("No #{blah.capitalize} found for you on #{server}\nPlease privately reply with:\n`Lita, Set #{blah.capitalize} for #{server} to #{blah.upcase}`")
        end
      end

      def set_user_pass(response)
        request = response.matches[0][0]
        server = response.matches[0][1]
        value = response.matches[0][2]
        id_server_user_pass = response.user.id + "_" + server + "_" + request.downcase

        if request && server && value
          redis.set(id_server_user_pass, value)
          response.reply_privately("#{request.capitalize} set")
          id_server_user = response.user.id + "_" + server + "_username"
          id_server_pass = response.user.id + "_" + server + "_password"
          if redis.get(id_server_user) && redis.get(id_server_pass)
            response.reply("Username and Password now set, please rerun your request")

          end
        else
          response.reply_privately("There seems to have been a problem setting that for you")
        end
      end

      def flush_redis(response)
        redis.flushdb
      end
      
      def set_server_port(response)
        request = response.matches[0][0]
        server = response.matches[0][1]
        value = response.matches[0][2]
        if request && server && value
          redis.set(id_server_port, value)
          id_server_port = response.user.id + "_" + server + "_port"
          if redis.get(id_server_port)
            response.reply("Server Port now set to #{value}")
          end
        else
          response.reply_privately("There seems to have been a problem setting that for you")
        end
      end


    end

    Lita.register_handler(SshRun)
  end
end
