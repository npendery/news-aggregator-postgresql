require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "news_aggregator_development")
    yield(connection)
  ensure
    connection.close
  end
end

get '/articles' do
  post_list = db_connection { |conn| conn.exec("SELECT * FROM articles") }.to_a
  erb :index, locals: {post_list: post_list}
end

get '/articles/new' do
  erb :show_new, locals: {url: params["url"]}
end

post '/articles/new' do
  erb :show_new, locals: {article_title: params["article_title"],
                          url: params["url"],
                          description: params["description"]}
  begin
  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (article_title, url, description) VALUES ($1, $2, $3)", [params["article_title"], params["url"], params["description"]]);
    # binding.pry
  end
    redirect '/articles'
  rescue
    redirect '/articles/new/error'
  end
end

get '/articles/new/error' do
  erb :error, locals: {url: params["url"]}
end

post '/articles/new/error' do
  erb :error, locals: {article_title: params["article_title"],
                          url: params["url"],
                          description: params["description"]}
  begin
  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (article_title, url, description) VALUES ($1, $2, $3)", [params["article_title"], params["url"], params["description"]]);
    # binding.pry
  end
    redirect '/articles'
  rescue
    redirect '/articles/new/error'
  end
end

# get 'articles/error' do
#   erb :error, locals: {article_title: params["article_title"],
#                           url: params["url"],
#                           description: params["description"]}
# end
