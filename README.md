# FlyingApk

FlyingApk is a clone of Testflight and only supports sharing of Android applications. FlyingApk hasn't had UI yet. It has only API and [Android client](https://github.com/lucky-dev/flying_apk_android).

## Install

1. `git clone https://github.com/lucky-dev/flying_apk_sinatra.git`
2. Install [Bundler](http://bundler.io/) `gem install bundler`
3. Go to the root directory of FlyingApk (where the file *Gemfile* is) and download all dependencies `bundle install`

## Using

### Development

1. Migrate database `rake db:migrate:development`
2. Start web server `rackup -p 8080`

## Test

1. Migrate database `rake db:migrate:test`
2. Run tests
	* For all routes `rspec -P ./spec/routes/**/*.rb`
	* For all models `rspec ./spec/models/*`
	* For all helpers `rspec ./spec/helpers/*`

## Production

1. Run MySQL server
2. Go to the MySQL console `mysql -h host -u root -p`
3. Create database `CREATE DATABASE flying_apk;`
4. Open file *config.yml*
5. In section `database -> production` change values of `host, user, password`
6. Run command `rake db:migrate:production`
7. Start web server `rackup --env production -p 8080`

### Other options

* Delete all files in the directory *public/files* `rake apk:delete`
* Delete database
	* `db:delete:test`
	* `db:delete:development`
	* `db:delete:production` *(Note: After deleting of the database `flying_apk`, you must create a new database manually through the command `CREATE DATABASE flying_apk;` in MySQL console. The command `rake db:migrate:production` doesn't create MySQL database automatically)*

## API

### User

#### Register

#### Login

#### Logout

### Android app

#### Create an app

#### Get list of apps

#### Update an app

#### Delete an app

#### Add an user to the app

#### Remove an user from the app

### Build

#### Create a build

#### Get list of builds

#### Update a build

#### Delete a build
