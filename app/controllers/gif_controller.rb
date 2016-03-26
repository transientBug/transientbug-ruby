class GifController < ApplicationController
  get '/gifs*' do
    pass if Feature.by_name(:gifs, namespace: :public).enabled?
  end

  get '/gifs' do
    @gif_names = Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*.gif') ].map do |img|
      img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' )
    end

    @gif_data = Gif.where(filename: @gif_names).inject({}) do |memo, gif|
      memo[gif.filename] = gif
      memo
    end

    @gifs = @gif_names.map do |gif|
      {
        file: gif,
        data: @gif_data[gif]
      }
    end

    haml :gifs
  end

  post '/gifs' do
    authenticate!

    redirect to("/gifs/#{ id }")
  end

  get '/gifs/search' do
  end

  get '/gifs/tags' do
  end

  get '/gifs/tag/:id' do
  end

  get '/gif/:id' do
    haml :gif
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
