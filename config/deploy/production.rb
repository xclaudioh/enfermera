set :ip, "45.79.158.208"
server "#{ip}", :web, :app, :db, primary: true
set :rails_env, 'production'