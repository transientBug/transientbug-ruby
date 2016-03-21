module FlashHelper
  def bulma_flash key: :flash
    return "" if flash(key).empty?
    id = (key == :flash ? "flash" : "flash-#{key}")

    messages = flash(key).collect do |type, msg|
      className = case type
      when :error
        'is-danger'
      when :warning
        'is-warning'
      when :success
        'is-success'
      when :info
        'is-info'
      else
        ''
      end
      "<div class='notification #{ className } flash #{ type }'>#{ msg }</div>"
    end

    "<div class='container' id='#{ id }'>#{ messages.join }</div>"
  end
end
