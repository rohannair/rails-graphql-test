bundle install
bundle config build.sassc "--disable-lto"
bundle exec rails new -d=postgresql -f .
initdb -D postgres