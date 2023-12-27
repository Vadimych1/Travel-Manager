# Travel-Manager
Here is project documentation

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

Any of methods in `api/v1` have requred parameters:
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