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
  erb :show_new
end

post '/articles/new' do
  erb :show_new, locals: {article_title: params["article_title"],
                          url: params["url"],
                          description: params["description"]}

  # CSV.open('news_database.csv', "a", headers: true) do |file|
  #   file << [params["article_title"], params["url"], params["description"]]
  # end
  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (article_title, url, description) VALUES ($3)", [params["article_title"]], [params["url"]], [params["description"]])
  end

  redirect '/articles'
end

# get 'articles/error' do
#   erb :error, locals: {article_title: params["article_title"],
#                           url: params["url"],
#                           description: params["description"]}
# end
