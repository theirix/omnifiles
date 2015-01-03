# OmniFiles

File storage and shortener server.

OmniFiles is built with Sinatra and Rack and uses an sqlite database to store shortened
urls and statistics.

## Installation

OmniFiles is a Rack application and can be used as a gem or as a server in local directory.

### As a gem

1. Install a gem

        gem install omnifiles

2. Create a settings file `/path/to/settings.yaml` by copying `config/settings.yaml.example`.
Location of file must be specified in env variable `OMNIFILES_SETTINGS`.

3. Start an app as a Thin server

        OMNIFILES_SETTINGS=/path/to/settings.yaml omnifiles
Of course, you can provide any additional Thin options:

        OMNIFILES_SETTINGS=/path/to/settings.yaml omnifiles -l /var/log/omnifiles.log -P /var/run/omnifiles.pid -d

## As a rack app

OmniFiles can be started using `config.ru` with you favourite Rack server.

1. Clone a git repo

2. Install dependencies

        bundle install

3. Create a settings file `/path/to/settings.yaml` by copying `config/settings.yaml.example`.
Location of file must be specified in env variable `OMNIFILES_SETTINGS`.

4. Start Rack app

        rackup

## Usage

1. Storing files.
OmniFiles can store files by issuing an authenticated POST request

        % curl --digest -u user:secret -F "file=@/path/to/file.jpg" 'http://localhost:3000/store'
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

Please consult with the LICENSE.txt for license information.