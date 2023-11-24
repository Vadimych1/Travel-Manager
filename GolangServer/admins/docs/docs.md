# Travel Manager Server documentation

This is the documentation for the Travel Manager Server.

## About
It\`s an HTTP API server for mobile app Travel Manager. `For start run:`

```bash
go run .
```
or
```bash
./start.bat
```

Server will start at port 3030. You also can change it in `config.yml`.

## Usage
An API includes the following:

1. Travel plans:
- Get all travel plans [localhost:3030/get_all_travels](http://localhost:3030/get_all_travels)
- Get travel plan [localhost:3030/get_travel](http://localhost:3030/get_travel) (not competely implemented)*
- Create travel plan [localhost:3030/create_travel](http://localhost:3030/create_travel)
- Update travel plan [localhost:3030/update_travel](http://localhost:3030/update_travel) *(not competely implemented)*
- Delete travel plan [localhost:3030/delete_travel](http://localhost:3030/delete_travel) *(not competely implemented)*
2. Users:
- Register [localhost:3030/register](http://localhost:3030/register)
- Login [localhost:3030/login](http://localhost:3030/login)
- Update user [localhost:3030/update_user](http://localhost:3030/update_user) *(not competely implemented)*
- Delete user [localhost:3030/delete_user](http://localhost:3030/delete_user) *(not competely implemented)*

## Server interface
The server have the interface for admins which on the [localhost:3030/admins](http://localhost:3030/admins) (or on the port which you can change in `config.yml`). It has the following functions:

1. Database info:
- Users
- Travel plans
- SQL requests into DB
2. Server info:
- Server version
- Server uptime
- Debug info