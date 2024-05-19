# syntax = docker/dockerfile:1

# Node.jsダウンロード用ビルドステージ（元）
# FROM ruby:3.0.4 AS nodejs

# WORKDIR /tmp

# Node.jsのダウンロード（元）
# RUN curl -LO https://node.js.org/dist/v12.14.1/node-v12.14.1-linux-x64.tar.xz
# RUN tar xvf node-v12.14.1-linux-x64.tar.xz

# xz形式だとエラーとなったためgz形式に変更（これも後でコンパイルのところでエラーになる）
# RUN curl -LO https://node.js.org/dist/v12.14.1/node-v12.14.1-linux-x64.tar.gz
# RUN tar xvf node-v12.14.1-linux-x64.tar.gz
# RUN mv node-v12.14.1-linux-x64 node

# Node.jsダウンロード方法を簡略化してみる
FROM node:12.14.1 AS nodejs

# Railsプロジェクトインストール
FROM ruby:3.0.4

# node.jsをインストールしたイメージからnode.jsをコピーする（元）
# COPY --from=nodejs /tmp/node /opt/node
# ENV PATH /opt/node/bin:$PATH

# node.jsをインストールしたイメージからnode.jsをコピーする（簡略化した場合）
COPY --from=nodejs /usr/local/bin/node /usr/local/bin/node
COPY --from=nodejs /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs


# アプリケーション起動用のユーザを追加
RUN useradd -m -u 1000 rails
RUN mkdir /app && chown rails /app
USER rails

# yarnのインストール（元）
# RUN curl -o- L https://yarnpkg.com/install.sh | bash
# ENV PATH /home/rails/.yarn/bin:/home/rails/.config/yarn/global/node_modules/.bin:$PATH

# nodejsのインストール方法を変えたらyarnインストールでエラーになったためこちらも変更
# yarnをインストールするために必要なパッケージをインストール
# 権限でエラーとなったために一時的にrootユーザーに切り替える
USER root
RUN apt-get update && apt-get install -y curl

# yarnのインストール（変更）
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

# ユーザーをrailsに戻す
USER rails

# ruby2.7以上でrails newをするとruby-2.6系で同梱されているbundlerとメジャーバージョンが異なるためbunddlerを実行できなくなる
# そのため、明示的にbundlerを最新にupdateする
RUN gem install bundler

WORKDIR /app

# Dockerのビルドステップキャッシュを利用するため、先にGemfileを転送し、bundle installを実行する
COPY --chown=rails Gemfile Gemfile.lock package.json yarn.lock /app/

RUN bundle install
RUN yarn install

COPY --chown=rails . /app

RUN bin/rails assets:precompile

VOLUME /app/public

# 実行時にコマンド指定がない場合に実行されるコマンド
CMD ["bin/rails", "s", "-b", "0.0.0.0"]



# # Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
# ARG RUBY_VERSION=3.0.4
# FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# # Rails app lives here
# WORKDIR /rails

# # Set production environment
# ENV RAILS_ENV="production" \
#     BUNDLE_DEPLOYMENT="1" \
#     BUNDLE_PATH="/usr/local/bundle" \
#     BUNDLE_WITHOUT="development"


# # Throw-away build stage to reduce size of final image
# FROM base as build

# # Install packages needed to build gems
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# # Install application gems
# COPY Gemfile Gemfile.lock ./
# RUN bundle install && \
#     rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
#     bundle exec bootsnap precompile --gemfile

# # Copy application code
# COPY . .

# # Precompile bootsnap code for faster boot times
# RUN bundle exec bootsnap precompile app/ lib/

# # Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# # Final stage for app image
# FROM base

# # Install packages needed for deployment
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Copy built artifacts: gems, application
# COPY --from=build /usr/local/bundle /usr/local/bundle
# COPY --from=build /rails /rails

# # Run and own only the runtime files as a non-root user for security
# RUN useradd rails --create-home --shell /bin/bash && \
#     chown -R rails:rails db log storage tmp
# USER rails:rails

# # Entrypoint prepares the database.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # Start the server by default, this can be overwritten at runtime
# EXPOSE 3000
# CMD ["./bin/rails", "server"]
