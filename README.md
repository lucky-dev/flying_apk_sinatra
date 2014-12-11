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
8. **In the file *config.yml* Change value of `security -> production -> password_salt` from `IknowThatIKnowNothing` to another value (phrase, word and etc).**

### Other options

* Delete all files in the directory *public/files* `rake apk:delete`
* Delete database
	* `db:delete:test`
	* `db:delete:development`
	* `db:delete:production` *(Note: After deleting of the database `flying_apk`, you must create a new database manually through the command `CREATE DATABASE flying_apk;` in MySQL console. The command `rake db:migrate:production` doesn't create MySQL database automatically)*
* Put a new version of the [Android client](https://github.com/lucky-dev/flying_apk_android) in the directory `./public/upd_app`. Your users get a new version of the app.
    * `checksum_file`: hash of the file
    * `file`: apk file (new version)
    * `version_app`: version (code, e.g. 1, 2, 3, ...) of the app
    * `version_name_app`: version (name, e.g. "1.0", "1.1", "1.2", ...) of the app
    * `whats_new`: new features of the app

## API

### User

#### Register
* Method: `POST`
* Path: `api/register`
* Header: `Accept: application/vnd.flyingapk; version=1`
* Params: `name`, `email`, `password`
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -d "name=Bob&email=bob@gmail.com&password=bob123" http://localhost:8080/api/register`
    * Response: ```{"api_version":1,"response":{"access_token":"c90d1afb0b67829b24f9d217a717a1f8"}}```

#### Login
* Method: `POST`
* Path: `api/login`
* Header: `Accept: application/vnd.flyingapk; version=1`
* Params: `email`, `password`
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -d "email=bob@gmail.com&password=bob123" http://localhost:8080/api/login`
    * Response: ```{"api_version":1,"response":{"access_token":"f9a8c642dd930ff680aa8d041041c882"}}```

#### Logout
* Method: `POST`
* Path: `api/logout`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: f9a8c642dd930ff680aa8d041041c882`
* Params: none
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: f9a8c642dd930ff680aa8d041041c882" -d "" http://localhost:8080/api/logout`
    * Response: ```{"api_version":1,"response":{"user_id":1}}```

### Android app

#### Create an app
* Method: `POST`
* Path: `api/android_apps`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: `name`, `description`
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" -d "name=\"Cool app\"&description=\"My cool app\"" http://localhost:8080/api/android_apps`
    * Response: ```{"api_version":1,"response":{"android_app":{"id":1,"name":"\"Cool app\"","description":"\"My cool app\""}}}```

#### Get list of apps
* Method: `GET`
* Path: `api/android_apps`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: none
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" http://localhost:8080/api/android_apps`
    * Response: ```{"api_version":1,"response":{"apps":[{"id":1,"name":"\"Cool app\"","description":"\"My cool app\""}]}}```

#### Update an app
* Method: `PUT`
* Path: `api/android_apps/:id`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: `name` or/and `description`
* Examples:
    * Request: `curl -X PUT -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" -d "description=\"New description\"" http://localhost:8080/api/android_apps/1`
    * Response: ```{"api_version":1,"response":{"app":{"name":"\"Cool app\"","description":"\"New description\""}}}```

#### Delete an app
* Method: `DELETE`
* Path: `api/android_apps/:id`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: none
* Examples:
    * Request: `curl -X DELETE -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" http://localhost:8080/api/android_apps/1`
    * Response: ```{"api_version":1,"response":{"app":{"id":1}}}```

#### Add an user to the app
* Method: `POST`
* Path: `api/android_apps/:id/add_user`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: `email`
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" -d "email=max@gmail.com" http://localhost:8080/api/android_apps/2/add_user`
    * Response: ```{"api_version":1,"response":{"permission":{"user_id":2}}}```

#### Remove an user from the app
* Method: `POST`
* Path: `api/android_apps/:id/remove_user`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: `email`
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" -d "email=max@gmail.com" http://localhost:8080/api/android_apps/2/remove_user`
    * Response: ```{"api_version":1,"response":{"permission":{"user_id":2}}}```

### Build

#### Create a build
* Method: `POST`
* Path: `api/builds`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: `version`, `fixes`, `file`
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" -F "version=1.0" -F "fixes=\"All bugs were fixed\"" -F "file=@/Users/vladimir/Documents/rails_projects/flying_apk/spec/fixture/my_app.apk" http://localhost:8080/api/builds?app_id=2`
    * Response: ```{"api_version":1,"response":{"build":{"id":1,"version":"1.0","fixes":"\"All bugs were fixed\"","created_time":"2014-12-09 11:50:29 +0200","file_name":"f8d3c10a4a63a14175c77a50ad5955b6.apk","file_checksum":"ea6e9d41130509444421709610432ee1"}}}```

#### Get list of builds
* Method: `GET`
* Path: `api/builds`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: none
* Examples:
    * Request: `curl -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" http://localhost:8080/api/builds?app_id=2`
    * Response: ```{"api_version":1,"response":{"builds":[{"id":1,"version":"1.0","fixes":"\"All bugs were fixed\"","created_time":"2014-12-09 11:50:29 +0200","file_name":"f8d3c10a4a63a14175c77a50ad5955b6.apk","file_checksum":"ea6e9d41130509444421709610432ee1"}]}}```

#### Update a build
* Method: `PUT`
* Path: `api/builds/:id`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: `version` or/and `fixes`
* Examples:
    * Request: `curl -X PUT -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" -d "fixes=\"New fixes\"" http://localhost:8080/api/builds/1`
    * Response: ```{"api_version":1,"response":{"build":{"id":1,"version":"1.0","fixes":"\"New fixes\""}}}```

#### Delete a build
* Method: `DELETE`
* Path: `api/builds/:id`
* Header: `Accept: application/vnd.flyingapk; version=1`, `Authorization: e6a21389ac37a3448b35087425736d77`
* Params: none
* Examples:
    * Request: `curl -X DELETE -H "Accept: application/vnd.flyingapk; version=1" -H "Authorization: e6a21389ac37a3448b35087425736d77" http://localhost:8080/api/builds/1`
    * Response: ```{"api_version":1,"response":{"build":{"id":1}}}```
