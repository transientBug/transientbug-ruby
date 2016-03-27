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

    gifs, @pagination = before_after_paginate gif_filenames

    gif_data = Gif.where(filename: gifs).inject({}) do |memo, gif|
      memo[gif.filename] = gif
      memo
    end

    @gifs = gifs.map do |gif|
      {
        file: gif,
        data: gif_data[gif]
      }
    end

    haml :'gifs/index'
  end

  get '/gifs/new' do
    authenticate!
    authorize!(resource: Feature.by_name(:gifs, namespace: :public), action: :create)

    @tags = DB[ "SELECT DISTINCT unnest(tags) as tag FROM gifs" ].map{ |a| a[:tag] }

    haml :'gifs/new'
  end

  post '/gifs/new' do
    authenticate!
    authorize!(resource: Feature.by_name(:gifs, namespace: :public), action: :create)

    tags = params[:tags].split(',').map{ |e| e.strip }.uniq
    enabled = params[:enabled] || false

    taken_short_codes = Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*') ].map do |img|
      name = img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' ).split '.'
      name.pop
      name.join '.'
    end

    gen_short_code = -> { SecureRandom.hex(5).upcase }
    short_code = gen_short_code[]
    while taken_short_codes.include? short_code
      short_code = gen_short_code[]
    end

    ext = params[:file][:filename].split('.').last
    filename = [ short_code, ext ].join '.'
    path = AshFrame.root.join 'public', 'images', 'gifs', filename

    gif = Gif.new title: params[:title],
                  tags: tags,
                  enabled: enabled,
                  short_code: short_code,
                  filename: filename,
                  user: current_user

    unless gif.valid?
      flash[:error] = gif.errors
      haml :'gifs/new'
      halt
    end

    File.open path, 'wb' do |f|
      f.write params[:file][:tempfile].read
    end

    gif.save

    redirect to("/gif/#{ filename }")
  end

  get '/gifs/search' do
    query = params[:q]

    @tags = DB[:tags].where{ tag.like "%#{ query }%" }.map{ |e| e[:tag] }
    if query.present?
      @gifs = Gif.where{ self.|( title.like("%#{ query }%"), tags.pg_array.contains([query]) ) }
    end

    haml :'gifs/search'
  end

  get '/gif/:id' do
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

    gif = gif[:filename]

    gif_metadata = Gif.find filename: gif

    if gif_metadata&.disabled?
      flash[:error] = "That gif does not exist"
      redirect to('/gifs')
    end

    @gif = {
      file: gif,
      data: gif_metadata
    }

    haml :'gifs/view'
  end

  patch '/gif/:id' do
    authenticate!
    authorize!(resource: Feature.by_name(:gifs, namespace: :public), action: :edit)

    redirect to("/gifs/#{ id }")
  end

  delete '/gif/:id' do
    authenticate!
    authorize!(resource: Feature.by_name(:gifs, namespace: :public), action: :delete)

    redirect to('/gifs')
  end
end
