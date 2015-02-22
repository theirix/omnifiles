# OmniFiles

[![Gem Version](https://img.shields.io/gem/v/omnifiles.svg)](https://rubygems.org/gems/omnifiles)
[![Code Climate](https://codeclimate.com/github/theirix/omnifiles/badges/gpa.svg)](https://codeclimate.com/github/theirix/omnifiles)
[![Dependency Status](https://gemnasium.com/theirix/omnifiles.svg)](https://gemnasium.com/theirix/omnifiles)

File storage and shortener server.

OmniFiles is built with Sinatra and Rack and uses an Mongo database to store shortened
urls and statistics.

## Installation

OmniFiles is a Sinatra/Rack application and can be used as a gem or as a server in local directory.

### As a gem

1. Install a gem

        gem install omnifiles

2. Point an env variable `OMNIFILES_SETTINGS` to location of a settings file `/path/to/settings.yaml` (see Configurarion).

3. Start an app as a Thin server

        OMNIFILES_SETTINGS=/path/to/settings.yaml omnifiles
Of course, you can provide any additional Thin options at command line:

        OMNIFILES_SETTINGS=/path/to/settings.yaml omnifiles -p 3000
Or at config file (see Thin documentation):

        OMNIFILES_SETTINGS=/path/to/settings.yaml omnifiles -C /path/to/thin.yaml


## As a rack app

OmniFiles can be started using `config.ru` with you favourite Rack server.

1. Clone a git repo

2. Install dependencies

        bundle install

3. Point an env variable `OMNIFILES_SETTINGS` to location of a settings file `/path/to/settings.yaml` (see Configurarion).

4. Start Rack app

        rackup

## Configuration

Settings file template can be found at `config/settings.yaml.example`.

If you prefer production Rack environment, please use `production` instead of `development` section in the config.
Also specify `-E production` at `omnifiles` (actially Thin) command line.

If you prefer to run omnifiles as a daemon, don't forget to set log and pid location. Author prefer to follow XDG and place all the files at the `~/.local/share/omnifiles`, including the database. So one can use following command line:

    OMNIFILES_SETTINGS=$HOME/.local/share/omnifiles/settings.yaml omnifiles start -d -a 127.0.0.1 -p 3000 \
      -l $HOME/.local/share/omnifiles/omnifiles.log \
      -P $HOME/.local/share/omnifiles/omnifiles.pid

Complex Thin options can be hidden in Thin config.yaml file:

    OMNIFILES_SETTINGS=$HOME/.local/share/omnifiles/settings.yaml omnifiles start -C $HOME/.local/share/omnifiles/thin.yaml

Note that OmniFiles and Thin configs are two distinct configs.

## Usage

1. Storing files.
OmniFiles can store files by issuing an authenticated POST form request:

        % curl --digest -u user:secret -F "file=@/path/to/file.jpg" 'http://localhost:3000/store'
        http://localhost:3000/f/e63A12
Or you can post a file just as a binary POST data:

        % curl --digest -u user:secret -H "Content-Type: application/octet-stream" --data-binary "@/path/to/file.jpg" 'http://localhost:3000/store'
        http://localhost:3000/f/e63A12
OmniFiles returns a short url in response so you can just issue following command to save URL in clipboard

        % curl --digest -u user:secret -F "file=@/path/to/file.jpg" 'http://localhost:3000/store' | pbcopy

2. Accessing files.
Just access given URL:

        % curl http://localhost:3000/f/e63A12
OmniFiles remembers MIME type and composes a correct typed response.
Header `X-Original-Filename` contains escaped original filename.

3. Viewing statistics.
OmniFiles provides file access statistics using authenticated requests.
Visit an url

        http://localhost:3000/stat/e63A12
using web browser or curl

## License information

Please consult with the LICENSE.txt for license information. It is MIT by the way.
