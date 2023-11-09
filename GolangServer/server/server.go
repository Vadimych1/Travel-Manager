package server

import (
	"fmt"
	"golangserver/GolangServer/server/database"
	"net/http"
	"strings"
)

// const vkapi_townsearch_key = "2320e98d2320e98d2320e98d652035789d223202320e98d47da2fa056600b3052f44d4c"

func Start() {
	database.Init()
	ip := ":80"

	fmt.Println("Starting HTTP server on", ip)

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		path := r.URL.Path
		args := r.URL.RawQuery

		if path != "/favicon.ico" && path != "/" {
			args_list := strings.Split(args, "&")
			args_map := make(map[string]string)

			fmt.Println("Path", path, "Args", args)

			fmt.Println("Args list", args_list, "Len", len(args_list), "; Args map", args_map)

			if len(args) > 0 {
				for i := 0; i < len(args_list); i++ {
					args_ := strings.Split(args_list[i], "=")
					fmt.Println(args_)
					args_map[args_[0]] = args_[1]
				}
			}

			// logic
			if path == "/login" {
				login := args_map["login"]
				phone := args_map["phone"]
				password := args_map["password"]

				if login != "" && password != "" {
					user, err := database.FindUser(login, "username")

					if err != nil {
						// fmt.Println(err)
						fmt.Fprint(w, "USER NOT EXISTS")
						return
					}

					if user["password"] == password {
						session, err := database.CreateSession(user["username"])

						if err != nil {
							fmt.Println(err)
							fmt.Fprint(w, "BAD REQUEST")
							return
						}

						fmt.Fprint(w, "sessionid:"+fmt.Sprint(session)+";username:"+user["username"])
					}
				} else if phone != "" && password != "" {
					user, err := database.FindUser(phone, "phone")

					if err != nil {
						fmt.Println(err)
						fmt.Fprint(w, "USER NOT EXISTS")
						return
					}

					if user["password"] == password {
						session, err := database.CreateSession(user["username"])

						if err != nil {
							fmt.Println(err)
							fmt.Fprint(w, "BAD REQUEST")
							return
						}

						fmt.Fprint(w, "sessionid:"+fmt.Sprint(session)+";username:"+user["username"])
					}
				} else {
					fmt.Fprint(w, "BAD REQUEST")
				}
			} else if path == "/register" {
				username := args_map["login"]
				password := args_map["password"]
				name := args_map["name"]
				phone := args_map["phone"]

				uid, err := database.InsertUser(username, password, name, phone)
				fmt.Println(uid)

				if err != nil {
					fmt.Fprint(w, err)
				} else {
					sessid, err := database.CreateSession(username)
					if err != nil {
						fmt.Fprint(w, err)
					}

					fmt.Fprint(w, "sessionid:"+fmt.Sprint(sessid)+";username:"+username)
				}
			}

		} else {
			fmt.Fprint(w, "NOT IMPLEMENTED")
		}
	})

	fmt.Println("Server started")
	http.ListenAndServe(ip, nil)
}
