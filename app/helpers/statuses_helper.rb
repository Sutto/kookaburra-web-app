module Merb
  module StatusesHelper

    def message_format(message)
      t = message.contents.dup
      t.gsub! /@([A-Za-z][A-Za-z\-\_0-9]+[A-Za-z])/ do |match|
        "@" + reply_to(h(match[1..-1]))
      end
      unless t.split(" ").include?(message.target) || message.target.downcase == "#general"
        t += " #{message.target}"
      end
      t += "<span class='reply-to-link'>#{reply_to message.from, '(reply)'}</span>"
      return t
    end
    
    def reply_to(username, text = nil)
      link_to h(text || username), "#", :onclick => "setReplyTo('#{username}'); return false;"
    end

  end
end # Merb