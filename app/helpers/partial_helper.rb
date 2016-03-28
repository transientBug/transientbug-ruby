module PartialHelper
  def partial(page, options={})
    page = page.to_s.split('/')
    last = page.pop
    page.push '_' + last
    page = page.join '/'

    haml page.to_sym, options.merge!(layout: false)
  end
end
