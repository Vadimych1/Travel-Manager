package main

import (
	"crypto/aes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"log"

	"fmt"
	"net/http"
	"os"
	"reflect"
	"strings"

	userdb "golangserver/GolangServer/sqldatabase"
)

func getFieldString(e *userdb.User, field string) string {
	r := reflect.ValueOf(e)
	f := reflect.Indirect(r).FieldByName(field)
	return f.String()
}

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

// // func DecryptAES(key []byte, ct string) string {
// // 	ciphertext, _ := hex.DecodeString(ct)

// // 	c, err := aes.NewCipher(key)
// // 	if err != nil {
// // 		log.Fatal(err)
// // 	}

// // 	pt := make([]byte, len(ciphertext))
// // 	c.Decrypt(pt, ciphertext)

// // 	s := string(pt[:])
// // 	return s
// // }

var encode_key string

func main() {
	fmt.Print("Starting HTTP server on localhost:3030", "\n")
	contents, _ := os.ReadFile("encode.key")
	encode_key = string(contents)

	userdb.Init()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		var s = r.URL.Path

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
				hash.Write([]byte(params["password"]))

				hs := hash.Sum(nil)

				enc := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

				println(enc)

				if userdb.InsertUser(params["username"], enc, params["name"]) {
					fmt.Fprint(w, `{"status":"success"}`)
				} else {
					fmt.Fprint(w, `{"status":"error", "code":"user_exists"}`)
				}
			} else {
				fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
			}
		case "/login", "/login/":
			if params["username"] != "" && params["password"] != "" {
				res := userdb.SearchUser(params["username"])
				if len(res) > 0 {
					var m = res[0]

					dbpwd := getFieldString(&m, "password")
					usrpwd := params["password"]

					hash := sha256.New()
					hash.Write([]byte(usrpwd))
					hs := hash.Sum(nil)

					dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

					fmt.Println(dec, " ", dbpwd)

					if dec == dbpwd {
						fmt.Fprint(w, `{"status":"success"}`)
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
			if params["username"] != "" &&
				params["password"] != "" &&
				params["plan_name"] != "" &&
				params["activities"] != "" &&
				params["from_date"] != "" &&
				params["to_date"] != "" &&
				params["live_place"] != "" &&
				params["budget"] != "" &&
				params["expenses"] != "" {

				res := userdb.SearchUser(params["username"])
				if len(res) > 0 {
					var m = res[0]

					dbpwd := getFieldString(&m, "password")
					usrpwd := params["password"]

					hash := sha256.New()
					hash.Write([]byte(usrpwd))
					hs := hash.Sum(nil)

					dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

					fmt.Println(dec, " ", dbpwd)

					if dec == dbpwd {
						if (userdb.InsertPlan(
							userdb.Travel{
								Owner:      params["username"],
								Plan_name:  params["plan_name"],
								Expenses:   params["expenses"],
								Activities: params["activities"],
								From_date:  params["from_date"],
								To_date:    params["to_date"],
								Live_place: params["live_place"],
								Budget:     params["budget"],
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
			if params["username"] != "" && params["password"] != "" {
				res := userdb.SearchUser(params["username"])
				if len(res) > 0 {
					var m = res[0]

					dbpwd := getFieldString(&m, "Password")
					fmt.Println(dbpwd, "pwd")
					usrpwd := params["password"]

					hash := sha256.New()
					hash.Write([]byte(usrpwd))
					hs := hash.Sum(nil)

					dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

					fmt.Println("1.", dec, "2.", dbpwd, "passwords")

					if dec == dbpwd {
						travels, err := userdb.SearchAllPlans(params["username"])

						if err != nil {
							fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
							return
						}

						j, err := json.Marshal(travels)
						if err != nil {
							fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
							return
						}

						fmt.Fprint(w, `{"status":"success", "content":"`+string(j)+`"}`)
					} else {
						fmt.Fprint(w, `{"status":"error", "code":"invalid_password"}`)
					}
				} else {
					fmt.Fprint(w, `{"status": "error", "code":"user_not_exists"}`)
				}
			} else {
				fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
			}
		default:
			fmt.Fprint(w, `{"status":"error", "code":"404 method not found"}`)
		}
	})

	http.ListenAndServe(":3030", nil)
}
