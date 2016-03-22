class GifController < ApplicationController
  get '/gifs' do
    @gif_names = Dir[ AshFrame.root.join('public', 'gifs', '**/*.gif') ].map do |img|
      img.gsub( AshFrame.root.join('public', 'gifs').to_s + '/', '' )
    end

    @gif_data = Gif.where(file_key: @gif_names).inject({}) do |memo, gif|
      memo[gif.file_key] = gif
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

    redirect to("gifs/#{ id }")
  end

  get '/gifs/:id' do
    haml :gif
  end

  patch '/gifs/:id' do
    authenticate!

    redirect to("/gifs/#{ id }")
  end

  delete '/gifs/:id' do
    authenticate!

    redirect to('/gifs')
  end
end
