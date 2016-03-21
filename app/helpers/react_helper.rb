module ReactHelper
  def react_component name, data={}
    data = data.to_json unless data.kind_of? String
   "<div class='react-component' data-react='#{ name }' data-payload='#{ data }'></div>"
  end
end
