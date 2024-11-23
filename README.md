# topo2md

Convert RFC8345-topology data (json) to markdown

## Setup

Install [netomox](https://github.com/ool-mddo/netomox-exp) gem using bundler.

netomox gem is pushed on github packages. So, it need authentication to exec bundle install. One of method to set authentication credential of bundler is using BUNDLE_RUBYGEMS__PKG__GITHUB__COM environment variable like below:

* `USERNAME` : your github username
* `TOKEN` : your github personal access token (need `read:packages` scope)

```shell
# authentication credential of github packages
export BUNDLE_RUBYGEMS__PKG__GITHUB__COM="USERNAME:TOKEN"

# If you install gems into project local
# bundle config set --local path 'vendor/bundle'
bundle install
```
