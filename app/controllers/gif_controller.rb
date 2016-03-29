class GifController < ApplicationController
  include Pagination

  # Feature flipper for all of Gifs
  get '/gif*' do
    if Feature.by_name(:gifs, namespace: :public).disabled?
      haml :disabled
    else
      pass
    end
  end

  get '/gifs' do
    skip_gif_filenames = DB[:gifs].select(:filename).where(enabled: false).map{ |e| e[:filename] }

    gif_filenames = Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*') ].map do |img|
      img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' )
    end.reject{ |img| skip_gif_filenames.include? img }.sort

    gifs = paginate gif_filenames

    gif_data = Gif.where(filename: gifs.to_a).inject({}) do |memo, gif|
      memo[gif.filename] = gif
      memo
    end

    gifs.data.map! do |gif|
      next gif_data[gif] if gif_data.has_key? gif

      short_code = gif.split '.'
      short_code.pop

      OpenStruct.new filename: gif, short_code: short_code.join('.'), tags: []
    end

    @gifs = gifs

    haml :'gifs/index'
  end

  get '/gifs/disabled' do
    authenticate!
    authorize!(resource: Feature.by_name(:gifs, namespace: :public), action: :delete)

    skip_gif_filenames = DB[:gifs].select(:filename).where(enabled: false).map{ |e| e[:filename] }

    gif_filenames = Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*') ].map do |img|
      img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' )
    end.select{ |img| skip_gif_filenames.include? img }.sort

    gifs = paginate gif_filenames

    gif_data = Gif.where(filename: gifs.to_a).inject({}) do |memo, gif|
      memo[gif.filename] = gif
      memo
    end

    gifs.data.map! do |gif|
      next gif_data[gif] if gif_data.has_key? gif

      OpenStruct.new filename: gif, tags: []
    end

    @gifs = gifs

    haml :'gifs/disabled'
  end

  get '/gifs/new' do
    authenticate!
    authorize!(resource: Feature.by_name(:gifs, namespace: :public), action: :create)

    @tags = DB[:tags].map{ |e| e[:tag] }

    haml :'gifs/new'
  end

  post '/gifs/new' do
    authenticate!
    authorize!(resource: Feature.by_name(:gifs, namespace: :public), action: :create)

    tags = params[:tags].split(',').map{ |e| e.strip }.uniq
    enabled = params[:enabled] || false

    ext = params[:file][:filename].split('.').last
    block = Blocks::Gifs::Upload.call io_object: params[:file][:tempfile],
                                      extension: ext,
                                      user: current_user,
                                      title: params[:title],
                                      tags: tags, enabled: enabled

    if block.errors.any?
      flash[:error] = block.errors.map{ |e| e[:message] }
      halt
    end

    redirect to("/gif/#{ block.filename }")
  end

  get '/gifs/search' do
    query = params[:q]

    @tags = DB[:tags].where{ tag.like "%#{ query }%" }.map{ |e| e[:tag] }
    if query.present?
      # Sequel is awesome like this.
      # http://sequel.jeremyevans.net/rdoc-plugins/files/lib/sequel/extensions/pg_ops_rb.html
      @gifs = paginate Gif.where{ self.|( title.like("%#{ query }%"), tags.pg_array.contains([query]) ) }

    end

    haml :'gifs/search'
  end

  get '/gif/:id' do
    id = params[:id]

    filename_short_code = Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*') ].map do |img|
      filename = img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' )
      short_code = filename.split '.'
      short_code.pop

      OpenStruct.new short_code: short_code.join('.'), filename: filename
    end

    gif = filename_short_code.find do |hash|
      hash.filename == id || hash.short_code == id
    end

    unless gif
      flash[:error] = "That gif does not exist"
      redirect to('/gifs')
    end

    gif_metadata = Gif.find filename: gif.filename

    if gif_metadata&.disabled? && !current_user.can?(resource: Feature.by_name(:gifs, namespace: :public), action: :delete)
      flash[:error] = "That gif does not exist"
      redirect to('/gifs')
    else
      gif = gif_metadata
    end

    @gif = gif

    haml :'gifs/view'
  end

  post '/gif/:id' do
    authenticate!
    authorize!(resource: Feature.by_name(:gifs, namespace: :public), action: :edit)

    id = params[:id]

    filename_short_code = Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*') ].map do |img|
      filename = img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' )
      short_code = filename.split '.'
      short_code.pop

      { short_code: short_code.join('.'), filename: filename }
    end

    gif = filename_short_code.find do |hash|
      hash[:filename] == id || hash[:short_code] == id
    end

    unless gif
      flash[:error] = "That gif does not exist"
      redirect to('/gifs')
    end

    gif_metadata = Gif.find_or_create filename: gif[:filename] do |img|
      img.short_code = gif[:short_code]
      img.user = current_user
    end

    tags = params[:tags].split(',').map{ |e| e.strip }.uniq
    enabled = params[:enabled] || false

    gif_metadata.update title: params[:title], tags: tags, enabled: enabled

    redirect to("/gif/#{ id }")
  end
end
