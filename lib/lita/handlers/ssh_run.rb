module Lita
  module Handlers
    class SshRun < Handler
      require 'net/ssh'

      route(/^run(.+)\s+on(.+)/i, :run_ssh, command: true)

      route(/^Username\s+for(.+)\s+is(.+)/i, :set_user, command: true)

      route(/^Password\s+for(.+)\s+is(.+)/i, :set_pass, command: true)

      def run_ssh(response)

        cmd = response.matches[0][0]
        server = response.matches[0][1]
        user_server = response.user.id + "_" + server
        user_pass = redis.hgetall(user_server)
        get_user(response, server)                      unless user_pass['usernm']
        get_pass(response, server, user_pass['usernm']) unless user_pass['passwd']

        if user_pass['usernm'] && user_pass['passwd']
          respone.reply("I found user and password")
        end

        # Net::SSH.start(server, user_pass['usernm'], :password => user_pass['passwd']) do |ssh|
        #   output = ssh.exec!(cmd)
        #   response.reply(output)
        # end



      end

      def get_user(response, server)
        response.reply_privately("I did not find a user name for you tied to #{server}")
        response.reply_privately("Please privately reply with your username for #{server} with the following syntax")
        response.reply_privately("Lita, Username for #{server} is USERNM")
      end

      def set_user(response)
        server = response.matches[0][0]
        usernm = response.matches[0][1]
        user_server = response.user.id + "_" + server
        redis.mapped_hmset( user_server, { usernm: usernm } )
        response.reply_privately("Set username for #{server}")
        response.reply_privately("To change username in the future, privately reply to me with the following syntax")
        response.reply_privately("Lita, Username for #{server} is USERNM")
      end

      def get_pass(response, server, usernm)
        response.reply_privately("I did not find a password for #{usernm} tied to #{server}")
        response.reply_privately("Please privately reply with your password for #{server} with the following syntax")
        response.reply_privately("Lita, Password for #{server} is PASSWD")
      end

      def set_pass(response)
        server = response.matches[0][0]
        user_server = response.user.id + "_" + server
        user_pass = redis.hgetall(user_server)
        usernm = user_pass['usernm']
        passwd = response.matches[0][1]
        redis.mapped_hmset( user_server, { usernm: usernm, passwd: passwd } )
        response.reply_privately("Set password for #{server}")
        response.reply_privately("To change password in the future, privately reply to me with the following syntax")
        response.reply_privately("Lita, Passwd for #{server} is PASSWD")
      end


    end

    Lita.register_handler(SshRun)
  end
end
