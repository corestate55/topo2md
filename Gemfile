# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :production do
  source 'https://rubygems.pkg.github.com/ool-mddo' do
    gem 'netomox', '>= 0.10.0'
  end
end

group :development do
  gem 'rubocop', '>= 0.80'
end
