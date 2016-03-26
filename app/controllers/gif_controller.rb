class GifController < ApplicationController
  get '/gifs*' do
    pass if Feature.by_name(:gifs, namespace: :public).enabled?
  end

  get '/gifs' do
    gif_filenames = Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*.gif') ].map do |img|
      img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' )
    end.sort

    total = gif_filenames.length

    # Not fool proof but then again, meh, fuck it all
    gif_short_codes = gif_filenames.map do |filename|
      short_code = filename.split '.'
      short_code.pop
      short_code.join '.'
    end

    per_page = params['per_page'] || 18
    per_page -= 1 # Array end offset

    begin
      if params['after']
        range_start = gif_short_codes.index(params['after']) + 1
        range_end   = range_start + per_page
      elsif params['before']
        range_end   = gif_short_codes.index(params['before']) - 1
        range_start = range_end - per_page
      else
        range_start = 0
        range_end   = per_page
      end
    rescue
      range_start = 0
      range_end   = per_page
    end

    gif_short_codes = gif_short_codes[range_start..range_end]
    gif_filenames   = gif_filenames[range_start..range_end]

    gif_data = Gif.where(filename: gif_filenames).inject({}) do |memo, gif|
      memo[gif.filename] = gif
      memo
    end

    pagination_before = if range_start <= 0
               nil
             else
               gif_short_codes.first
             end

    pagination_after = if range_end >= total
              nil
            else
              gif_short_codes.last
            end

    @pagination = {
      before: pagination_before,
      after: pagination_after
    }

    @gifs = gif_filenames.map do |gif|
      {
        file: gif,
        data: gif_data[gif]
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
