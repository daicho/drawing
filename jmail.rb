require 'sinatra'
require 'digest/md5'
require 'active_record'

set :environment, :production
set :sessions,
    expire_after: 7200,
    secret: 'abcdefghij0123456789'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection :development

class Account < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

get '/' do
    redirect '/login'
end

get '/login' do
    erb :loginscr
end

post '/auth' do
    username = params[:uname]
    passwd = params[:pass]

    if Account.exists?(username)
        a = Account.find(username)
        db_username = a.id
        db_salt = a.salt
        db_hashed = a.hashed
        db_algo = a.algo

        if db_algo == "1"
            trial_hashed = Digest::MD5.hexdigest(db_salt + passwd)
        else
            puts "Unknown algorithm is userd for user #{username}."
            exit(-2)
        end

        if db_hashed == trial_hashed
            session[:login_flag] = true
            session[:testdata] = "Is this a holdup?"
            redirect '/contentspace'
        else
            session[:login_flag] = false
            redirect '/failure'
        end
    else
        session[:login_flag] = false
        redirect '/failure'
    end
end

get '/failure' do
    erb :failure
end

get '/contentspace' do
    if session[:login_flag] == true
        @a = session[:testdata]
        erb :contents
    else
        erb :badrequest
    end
end

get '/logout' do
    session.clear
    erb :logout
end
