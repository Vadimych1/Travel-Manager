[![wakatime](https://wakatime.com/badge/user/06ab9ab9-967b-46d2-9166-f0206df30b00/project/e3a6c69f-695d-410f-80be-531252a31e38.svg)](https://wakatime.com/badge/user/06ab9ab9-967b-46d2-9166-f0206df30b00/project/e3a6c69f-695d-410f-80be-531252a31e38)
 
# Travel-Manager
Here is project documentation

## Summary
1. <a href="#methods">Methods</a>
2. <a href="#configjson">About config.json</a>

## Documentation

### Methods:
- **api/v1**
    - create_travel
    - delete_travel
    - edit_travel
    - get_all_travels
    - get_travel
    - register
    - login
- **api/activities**
    - search
    - insert

Every methods can be requested with GET request.

Any of methods in `api/v1` have required parameters:
- username **(string)**
- password **(string)**

Method\`s `api/activities/search` required params is:
- username **(string)**
- password **(string)**
- q **(string)**
- town **(string)** *[format: "region town", ex: "московская область одинцово"]*

#### More about methods
Above is methods in `api/v1`. Read about other required params <a href="#methods">upper</a>.

* create_travel
    * required:
        * town **(string)**
        * from_date **(string)**
        * to_date **(string)**
        * name **(string)**
        * activities **(string [json])**
        * meta **(string [json])**
        * live_place **(string)** *[deprecated]*
        * budget **(int)**
        * expenses **(string)**
        * people_count **(string [adults;children])**
    * optional:
        * id **(int)**
* delete_travel
    * required:
        * id **(int)**
* edit_travel
    * required:
        * same as `create_travel`
        * id **(int)**
* get_all_travels
* get_travel
    * required:
        * id **(int)**
* register
    * required:
        * username **(string)**
        * password **(string)**
        * name **(string)**
* login
    * required:
        * username **(string)**
        * password **(string)**

**Returning values**
* Default form [json]:
    * status **(string)**
    * message **(string)**
    * data **(string)**
* On success [json]:
    * status [success]
    * data **(json)** [optional]
* On error [json]:
    * status [error]
    * message [about_err]
* On error (new) [string]:
    * message

## config.json
JSON formatted file with server configuration.

### Example:

```json
{
    "encode_key": "data_encode_key",
    "port": "80",
    "global": "true",
    "path": "/",
    "admin_pwd": "admin"
}
```
<br><br/>
***\*It\`s not recommended to change `encode_key` if server is on working state (means that server working with real users) (YOU WILL LOSE ALL USERS DATA FROM DATABASE)<br><br/>***
***\*\*To apply changes in config to server, you need to restart it***
