class GifController < ApplicationController
  include Pagination

  get '/gifs*' do
    if Feature.by_name(:gifs, namespace: :public).disabled?
      haml :disabled
    else
      pass
    end
  end

  get '/gifs' do
    gif_filenames = Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*.gif') ].map do |img|
      img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' )
    end.sort

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

    haml :'gifs/new'
  end

  post '/gifs/new' do
    authenticate!

    redirect to("/gifs/#{ id }")
  end

  get '/gifs/search' do
    haml :'gifs/search'
  end

  get '/gifs/tags' do
    haml :'gifs/tags'
  end

  get '/gif/:id' do
    haml :'gifs/view'
  end

  patch '/gif/:id' do
    authenticate!

    redirect to("/gifs/#{ id }")
  end

  delete '/gif/:id' do
    authenticate!

    redirect to('/gifs')
  end
end
