require 'cgi'
require 'sinatra'
require 'digest/md5'
require 'active_record'

# 投稿種類
TYPE_TEXT = 0
TYPE_DRAW = 1

# 各種設定
NAME_MAX = 32   # 名前の最大文字数
USERID_MAX = 32 # ユーザーIDの最大文字数
PASS_MAX = 32   # パスワードの最大文字数
PAGE_MAX = 10   # 1ページに表示できる最大件数
TEXT_MAX = 512  # 書き込みの最大文字数

set :environment, :production
set :sessions,
    expire_after: 7200,
    secret: 'naganokosen3818850'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection :development

class Account < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

# 投稿の件数に対するページ数を返す
def page_num(len)
    if len == 0
        return 1
    else
        return ((len - 1) / PAGE_MAX).to_i + 1
    end
end

# 1ページ目にリダイレクト
get '/' do
    posts_len = Post.all.length
    redirect "/#{page_num(posts_len)}"
end

# エラーページ
get '/error' do
    @title = 'Error'
    @ccs = 'error.css'
    erb :error
end

# 前のページへ
post '/prev' do
    page = params[:page].to_i - 1

    # 範囲内ならリダイレクト
    if page >= 1
        redirect "/#{page}"
    end
end

# 次のページへ
post '/next' do
    page = params[:page].to_i + 1

    # 範囲内ならリダイレクト
    if page <= page_num(Post.all.length)
        redirect "/#{page}"
    end
end

# テキスト投稿
post '/new_text' do
    if session[:login_flag]
        post = Post.new

        # 入力内容を取得
        text = params[:text].slice(0, TEXT_MAX)
        text = CGI.escapeHTML(text)
        text = text.gsub(/(\r\n|\r|\n)/, '<br>')

        # データベースへ書き込み
        post.number = Post.all.length + 1
        post.exist = 1
        post.kind = TYPE_TEXT
        post.time = Time.now.strftime('%Y/%m/%d(%a) %H:%M:%S')
        post.userid = session[:login_userid]
        post.text = text
        post.origin = 0
        post.save

        redirect '/'
    else
        redirect '/badrequest'
    end
end

# 投稿を削除
delete '/delete' do
    post = Post.find(params[:number])

    if session[:login_flag] && post.userid == session[:login_userid]
        post.exist = 0
        post.save
        redirect '/'
    else
        redirect '/badrequest'
    end
end

# お絵かき
get '/draw' do
    @title = 'イラスト投稿'
    @ccs = 'draw.css'
    erb :draw
end

# 新規登録
get '/signup' do
    @name_max = NAME_MAX
    @userid_max = USERID_MAX
    @pass_max = PASS_MAX
    @title = '新規登録'
    @ccs = 'signup.css'
    erb :signup
end

# ユーザー登録
post '/regist' do
    name = params[:name]
    userid = params[:userid]
    password = params[:password]
    re_password = params[:re_password]

    if password == re_password
        r = Random.new
        salt = Digest::MD5.hexdigest(r.bytes(20))
        hashed = Digest::MD5.hexdigest(salt + password)

        a = Account.new
        a.userid = userid
        a.salt = salt
        a.hashed = hashed
        a.name = name
        a.save

        session[:login_flag] = true
        session[:login_userid] = userid
        redirect '/'
    else
        redirect '/badrequest'
    end
end

# ログイン
get '/login' do
    @userid_max = USERID_MAX
    @pass_max = PASS_MAX
    @title = 'ログイン'
    @ccs = 'login.css'
    erb :login
end

# 認証
post '/auth' do
    userid = params[:userid]
    password = params[:password]

    if Account.exists?(userid)
        a = Account.find(userid)
        trial_hashed = Digest::MD5.hexdigest(a.salt + password)

        if a.hashed == trial_hashed
            session[:login_flag] = true
            session[:login_userid] = userid
            redirect '/'
        else
            session[:login_flag] = false
            redirect '/failure'
        end
    else
        session[:login_flag] = false
        redirect '/failure'
    end
end

# ログイン失敗
get '/failure' do
    @title = 'Login Failed'
    @ccs = 'failure.css'
    erb :failure
end

# ログアウト
get '/logout' do
    session.clear
    @title = 'ログアウト'
    @ccs = 'logout.css'
    erb :logout
end

# バッドリクエスト
get '/badrequest' do
    @title = 'Bad Request'
    @ccs = 'badrequest.css'
    erb :badrequest
end

# ページ指定
get '/:page' do
    # 数値が指定されているか
    if params[:page] =~ /^[0-9]+$/
        @page = params[:page].to_i
    else
        redirect '/error'
    end

    @last_page = page_num(Post.all.length)
    @page_max = PAGE_MAX
    @text_max = TEXT_MAX

    # 無効なページ数が指定されたらエラー
    if @page <= 0 or @last_page < @page
        redirect '/error'
    else
        @title = '掲示板'
        @ccs = 'bbs.css'
        erb :bbs
    end
end
