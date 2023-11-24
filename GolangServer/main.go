package main

import (
	"crypto/aes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"reflect"
	"strconv"
	"strings"

	userdb "golangserver/GolangServer/db"
)

func getFieldString(e *userdb.User, field string) string {
	r := reflect.ValueOf(e)
	f := reflect.Indirect(r).FieldByName(field)
	return f.String()
}

// EncryptAES encrypts the given plaintext using AES encryption with the provided key.
// It returns the encrypted ciphertext as a hexadecimal string.
func EncryptAES(key []byte, plaintext string) string {
	// create cipher
	c, err := aes.NewCipher(key)
	if err != nil {
		log.Fatal(err)
	}
	out := make([]byte, len(plaintext))
	c.Encrypt(out, []byte(plaintext))
	return hex.EncodeToString(out)
}

func ReadSettings() map[string]string {
	ret := map[string]string{}

	read, _ := os.ReadFile("config.json")
	err := json.Unmarshal(read, &ret)

	if err != nil {
		log.Fatal(err)
	}

	return ret
}

var logfile, _ = os.OpenFile(fmt.Sprintf("logs/log-%d-%d-%d.log", log.LUTC, log.Ldate, log.Ltime), os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
var logger = log.New(io.Writer(logfile), "", 0)

func Log(toLog string) {
	logger.Println(toLog)
	log.Default().Println(toLog)
}

var encode_key string

func main() {
	logger.Println("----------------------------------\nAfter restart\n----------------------------------")
	settings := ReadSettings()

	Log("Starting HTTP server on " + string(settings["port"]))
	encode_key = string(settings["encode_key"])

	userdb.Init(logger)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		var s, _ = url.QueryUnescape(r.URL.Path)

		var params map[string]string
		if len(r.URL.RawQuery) > 0 {
			var params_ = strings.Split(r.URL.RawQuery, "&")
			params = map[string]string{}

			for _, v := range params_ {
				var s = strings.Split(v, "=")
				params[s[0]] = s[1]
			}
		}

		switch s {
		case "/register", "/register/":
			if params["username"] != "" && params["password"] != "" && params["name"] != "" {
				hash := sha256.New()
				res, _ := url.QueryUnescape(params["password"])
				hash.Write([]byte(res))
				hs := hash.Sum(nil)

				enc := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

				println(enc)

				res, _ = url.QueryUnescape(params["username"])
				res2, _ := url.QueryUnescape(params["name"])

				if userdb.InsertUser(res, enc, res2) {
					fmt.Fprint(w, `{"status":"success"}`)
				} else {
					fmt.Fprint(w, `{"status":"error", "code":"user_exists"}`)
				}
			} else {
				fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
			}
		case "/login", "/login/":
			// fmt.Println("login")

			if params["username"] != "" && params["password"] != "" {
				r, _ := url.QueryUnescape(params["username"])
				fmt.Println(r)
				res := userdb.SearchUser(r)

				if len(res) > 0 {
					var m = res[0]

					dbpwd := getFieldString(&m, "Password")
					usrpwd := params["password"]

					hash := sha256.New()
					hash.Write([]byte(usrpwd))
					hs := hash.Sum(nil)

					dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

					if dec == dbpwd {
						fmt.Fprint(w, `{"status":"success", "name":"`+getFieldString(&m, "Name")+`", "subscribe":"`+getFieldString(&m, "Subscribe")+`"}`)
					} else {
						fmt.Fprint(w, `{"status":"error", "code":"invalid_password"}`)
					}
				} else {
					fmt.Fprint(w, `{"status": "error", "code":"user_not_exists"}`)
				}
			} else {
				fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
			}
		case "/create_travel", "/create_travel/":
			// fmt.Println("creating travel")

			if params["username"] != "" &&
				params["password"] != "" &&
				params["plan_name"] != "" &&
				params["activities"] != "" &&
				params["from_date"] != "" &&
				params["to_date"] != "" &&
				params["live_place"] != "" &&
				params["budget"] != "" &&
				params["expenses"] != "" &&
				params["people_count"] != "" &&
				params["meta"] != "" &&
				params["town"] != "" {
				usr, _ := url.QueryUnescape(params["username"])
				fmt.Println("Username:", usr) // debug
				res := userdb.SearchUser(usr)

				if len(res) > 0 {
					var m = res[0]

					dbpwd := getFieldString(&m, "Password")
					usrpwd := params["password"]

					hash := sha256.New()
					hash.Write([]byte(usrpwd))
					hs := hash.Sum(nil)

					dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

					fmt.Println(dec, " ", dbpwd) // debug

					if dec == dbpwd {
						if (userdb.InsertPlan(
							userdb.Travel{
								Owner:       usr,
								Plan_name:   params["plan_name"],
								Expenses:    params["expenses"],
								Activities:  params["activities"],
								From_date:   params["from_date"],
								To_date:     params["to_date"],
								Live_place:  params["live_place"],
								Budget:      params["budget"],
								PeopleCount: params["people_count"],
								Meta:        params["meta"],
								Town:        params["town"],
							},
						)) {
							fmt.Fprint(w, `{"status":"success"}`)
						} else {
							fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
						}

					} else {
						fmt.Fprint(w, `{"status":"error", "code":"invalid_password"}`)
					}
				} else {
					fmt.Fprint(w, `{"status": "error", "code":"user_not_exists"}`)
				}
			} else {
				fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
			}
		case "/get_all_travels", "/get_all_travels/":
			// fmt.Println("getting all travels...") // debug

			if params["username"] != "" && params["password"] != "" {
				r, _ := url.QueryUnescape(params["username"])
				res := userdb.SearchUser(r)

				if len(res) > 0 {
					var m = res[0]

					dbpwd := getFieldString(&m, "Password")
					usrpwd := params["password"]

					hash := sha256.New()
					hash.Write([]byte(usrpwd))
					hs := hash.Sum(nil)

					dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

					if dec == dbpwd {
						travels, err := userdb.SearchAllPlans(r)

						if err != nil {
							fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
							Log("Server error") // debug
							return
						}

						j, err := json.Marshal(travels)
						if err != nil {
							Log("Server error") // debug
							fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
							return
						}

						fmt.Fprint(w, `{"status":"success", "content":`+string(j)+`}`)
					} else {
						fmt.Fprint(w, `{"status":"error", "code":"invalid_password"}`)
					}
				} else {
					fmt.Fprint(w, `{"status": "error", "code":"user_not_exists"}`)
				}
			} else {
				fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
			}
		case "/get_travel", "/get_travel/":
			if params["username"] != "" && params["password"] != "" && params["id"] != "" {
				r, _ := url.QueryUnescape(params["username"])
				res := userdb.SearchUser(r)

				if len(res) > 0 {
					var m = res[0]
					dbpwd := getFieldString(&m, "Password")
					usrpwd := params["password"]

					hash := sha256.New()
					hash.Write([]byte(usrpwd))
					hs := hash.Sum(nil)

					dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

					if dec == dbpwd {
						id, _ := strconv.Atoi(params["id"])
						travel, err := userdb.SearchTravel(id, r)

						j, err := json.Marshal(travel)
						if err != nil {
							Log("Server error") // debug
							fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
							return
						}

						fmt.Fprint(w, `{"status":"success", "content":`+string(j)+`}`)
					} else {
						fmt.Fprint(w, `{"status":"error", "code":"invalid_password"}`)
					}
				}
			}
		case "/admins", "/admins/":
			if r.Method == "GET" {
				if params["page"] == "" || params["pwd"] == "" {
					rd, _ := os.ReadFile("./admins/login/login.html")
					fmt.Fprint(w, string(rd))
				} else {
					if params["pwd"] == settings["admin_pwd"] {
						rd, _ := os.ReadFile("./admins/" + params["page"] + ".html")
						fmt.Fprint(w, string(rd))
					} else {
						params["page"] = "login_e"
						rd, _ := os.ReadFile("./admins/login/login_e.html")
						fmt.Fprint(w, string(rd))
					}
				}

			} else if r.Method == "POST" {
				r.ParseForm()
				log_, _ := os.ReadFile(fmt.Sprintf("logs/log-%d-%d-%d.log", log.LUTC, log.Ldate, log.Ltime))
				if r.URL.Path == "/admins" || r.URL.Path == "/admins/" {
					switch r.PostForm.Get("action") {
					case "login":
						if r.PostForm.Get("pwd") == settings["admin_pwd"] {
							rd, _ := os.ReadFile("./admins/" + r.PostForm.Get("page") + ".html")
							fmt.Fprint(w, strings.ReplaceAll(strings.ReplaceAll(
								strings.ReplaceAll(string(rd),
									"%password",
									settings["admin_pwd"],
								), "%port", settings["port"],
							), "%log", string(log_),
							),
							)
						} else {
							rd, _ := os.ReadFile("./admins/login/login_e.html")
							fmt.Fprint(w, strings.ReplaceAll(strings.ReplaceAll(
								strings.ReplaceAll(string(rd),
									"%password",
									settings["admin_pwd"],
								), "%port", settings["port"],
							), "%log", string(log_),
							),
							)
						}
					case "update_config":
						if r.PostForm.Get("pwd") == settings["admin_pwd"] {
							settings = ReadSettings()
							rd, _ := os.ReadFile("./admins/" + r.PostForm.Get("page") + ".html")
							fmt.Fprint(w, strings.ReplaceAll(strings.ReplaceAll(
								strings.ReplaceAll(string(rd),
									"%password",
									settings["admin_pwd"],
								), "%port", settings["port"],
							), "%log", string(log_),
							),
							)
						}
					default:
						rd, _ := os.ReadFile("./admins/login/login.html")
						fmt.Fprint(w, string(rd))
					}
				} else {
					rd, _ := os.ReadFile("./admins/e404.html")
					fmt.Fprint(w, string(rd))
				}
			}
		default:
			fmt.Fprint(w, `{"status":"error", "code":"404 method not found"}`)
		}
	})

	Log("Server started successfully")
	if settings["global"] == "true" {
		e := http.ListenAndServe(":"+settings["port"], nil)

		if e != nil {
			Log(e.Error())
		}
	} else {
		e := http.ListenAndServe("localhost:"+settings["port"], nil)

		if e != nil {
			Log(e.Error())
		}
	}
}
