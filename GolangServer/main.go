package main

import (
	"bytes"
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
	"time"

	userdb "travel_server/db"
)

func getFieldString(e *userdb.User, field string) string {
	r := reflect.ValueOf(e)
	f := reflect.Indirect(r).FieldByName(field)
	return f.String()
}

// EncryptAES encrypts the given plaintext using AES encryption with the provided key.
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

// Read settings from config file
func ReadSettings() map[string]string {
	ret := map[string]string{}

	read, _ := os.ReadFile("config.json")
	err := json.Unmarshal(read, &ret)

	if err != nil {
		log.Fatal(err)
	}

	return ret
}

// Create loggers
var logfile, _ = os.OpenFile(fmt.Sprintf("logs/log-%d-%d-%d.log", log.LUTC, log.Ldate, log.Ltime), os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
var logger = log.New(io.Writer(logfile), "", 0)

// Print log
func Log(toLog string) {
	logger.Println(toLog)
	log.Default().Println(toLog)
}

var encode_key string

// Create user
func register(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["username"] != "" && params["password"] != "" && params["name"] != "" {
		hash := sha256.New()
		res, _ := url.QueryUnescape(params["password"])
		hash.Write([]byte(res))
		hs := hash.Sum(nil)

		enc := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

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
}

// Login user
func login(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["username"] != "" && params["password"] != "" {
		r, _ := url.QueryUnescape(params["username"])
		res := userdb.SearchUser(r)

		if len(res) > 0 {
			dbpwd := getFieldString(&res[0], "Password")
			usrpwd := params["password"]

			hash := sha256.New()
			hash.Write([]byte(usrpwd))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

			if dec == dbpwd {
				fmt.Fprint(w, `{"status":"success", "name":"`+getFieldString(&res[0], "Name")+`", "subscribe":"`+getFieldString(&res[0], "Subscribe")+`"}`)
			} else {
				fmt.Fprint(w, `{"status":"error", "code":"invalid_password"}`)
			}
		} else {
			fmt.Fprint(w, `{"status": "error", "code":"user_not_exists"}`)
		}
	} else {
		fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
	}
}

// Create plan in DB
func createTravel(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
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
		res := userdb.SearchUser(usr)

		if len(res) > 0 {
			var m = res[0]

			dbpwd := getFieldString(&m, "Password")
			usrpwd := params["password"]

			hash := sha256.New()
			hash.Write([]byte(usrpwd))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

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
}

// Fetch all travels
func getAllTravels(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
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
}

// Fetch travel plan from db
func getTravel(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
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
				travel, err := userdb.SearchPlan(id, r)
				if err != nil {
					fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
					Log("Server error") // debug
					return
				}

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
	} else {
		fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
	}
}

// Edit travel in DB
func editTravel(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	username := params["username"]
	password := params["password"]
	planName := params["plan_name"]
	activities := params["activities"]
	fromDate := params["from_date"]
	toDate := params["to_date"]
	livePlace := params["live_place"]
	budget := params["budget"]
	expenses := params["expenses"]
	peopleCount := params["people_count"]
	meta := params["meta"]
	town := params["town"]
	id := params["id"]

	if username != "" && password != "" && planName != "" && activities != "" &&
		fromDate != "" && toDate != "" && livePlace != "" && budget != "" &&
		expenses != "" && peopleCount != "" && meta != "" && town != "" && id != "" {
		usr, _ := url.QueryUnescape(username)
		res := userdb.SearchUser(usr)

		if len(res) > 0 {
			m := res[0]

			dbpwd := getFieldString(&m, "Password")
			usrpwd := password

			hash := sha256.New()
			hash.Write([]byte(usrpwd))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

			if dec == dbpwd {
				tid, _ := strconv.Atoi(id)
				if userdb.DeleteTravel(tid, usr) {
					if userdb.InsertPlan(userdb.Travel{
						Id:          id,
						Owner:       usr,
						Plan_name:   planName,
						Expenses:    expenses,
						Activities:  activities,
						From_date:   fromDate,
						To_date:     toDate,
						Live_place:  livePlace,
						Budget:      budget,
						PeopleCount: peopleCount,
						Meta:        meta,
						Town:        town,
					}) {
						fmt.Fprint(w, `{"status":"success"}`)
					} else {
						fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
					}
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
}

// Delete travel plan from DB
func deleteTravel(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["id"] != "" && params["username"] != "" && params["password"] != "" {
		usr, _ := url.QueryUnescape(params["username"])
		res := userdb.SearchUser(usr)

		if len(res) > 0 {
			m := res[0]

			dbpwd := m.Password
			usrpwd := params["password"]

			hash := sha256.New()
			hash.Write([]byte(usrpwd))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

			if dec == dbpwd {
				tid, _ := strconv.Atoi(params["id"])

				if userdb.DeleteTravel(tid, usr) {
					fmt.Fprint(w, `{"status":"success"}`)
				} else {
					fmt.Fprint(w, `{"status": "error", "code":"500 server error"}`)
				}
			}
		} else {
			fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
		}
	} else {
		fmt.Fprint(w, `{"status": "error", "code":"400 bad request"}`)
	}
}

// Admins panel get
func admins(params map[string]string, w http.ResponseWriter, r *http.Request, settings map[string]string) {
	if r.Method == "GET" {
		if params["page"] == "" || params["pwd"] == "" {
			rd, _ := os.ReadFile("./admins/login/login.html")
			fmt.Fprint(w, string(rd))
			return
		}

		if params["pwd"] == settings["admin_pwd"] {
			rd, _ := os.ReadFile("./admins/" + params["page"] + ".html")
			fmt.Fprint(w, string(rd))
			return
		}

		params["page"] = "login_e"
		rd, _ := os.ReadFile("./admins/login/login_e.html")
		fmt.Fprint(w, string(rd))

	} else if r.Method == "POST" {
		r.ParseForm()
		log_, _ := os.ReadFile(fmt.Sprintf("logs/log-%d-%d-%d.log", log.LUTC, log.Ldate, log.Ltime))

		if r.URL.Path == "/admins" || r.URL.Path == "/admins/" {
			switch r.PostForm.Get("action") {
			case "login":
				if r.PostForm.Get("pwd") == settings["admin_pwd"] {
					rd, _ := os.ReadFile("./admins/" + r.PostForm.Get("page") + ".html")
					fmt.Fprint(w, replacePlaceholders(string(rd), settings, string(log_)))
					return
				}

				rd, _ := os.ReadFile("./admins/login/login_e.html")
				fmt.Fprint(w, replacePlaceholders(string(rd), settings, string(log_)))

			case "update_config":
				if r.PostForm.Get("pwd") == settings["admin_pwd"] {
					settings = ReadSettings()
					rd, _ := os.ReadFile("./admins/" + r.PostForm.Get("page") + ".html")
					fmt.Fprint(w, replacePlaceholders(string(rd), settings, string(log_)))
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
}

// Default HTTP get
func default_get(params map[string]string, w http.ResponseWriter, r *http.Request, settings map[string]string, s string) {
	var err error
	var b []byte

	if err != nil {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprint(w, `<html><head><title>Error 404</title></head><body><h1>Error 404<h1></body></html>`)
		Log(err.Error())
		return
	}

	if strings.HasSuffix(s, "/") {
		s = s + "index.html"
	}

	// Get content
	b, err = os.ReadFile(fmt.Sprintf("./pages%s", s))
	if err != nil {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprint(w, `<html><head><title>Error 404</title></head><body><h1>Error 404<h1></body></html>`)
		Log(err.Error())
		return
	}

	// Get content type
	mtype := http.DetectContentType(b)
	w.Header().Set("Content-Type", mtype)

	sd := string(b)
	fmt.Fprint(w, sd)
}

// Remove travels that expired
func clearTravels() {
	rows, err := userdb.Db.Query("SELECT * FROM plans")

	if err != nil {
		Log(err.Error())
	}

	for rows.Next() {
		var id int
		var owner string
		var name string
		var activs string
		var from_date string
		var to_date string
		var live_place string
		var budget string
		var expenses string
		var meta string
		var town string
		var people_count string

		err = rows.Scan(&id, &owner, &name, &activs, &from_date, &to_date, &live_place, &budget, &expenses, &meta, &town, &people_count)

		if err != nil {
			Log(err.Error())
			continue
		}

		time_, err := time.Parse("02.01.2006", from_date)

		if err != nil {
			Log(err.Error())
			continue
		}

		if time_.Compare(time.Now()) < 0 {
			userdb.DeleteTravel(id, owner)
			// Log("Deleting...")
		}
	}

	rows.Close()
}

// Replace placeholders in documents
func replacePlaceholders(content string, settings map[string]string, log string) string {
	return strings.ReplaceAll(strings.ReplaceAll(
		strings.ReplaceAll(content,
			"%password",
			settings["admin_pwd"],
		), "%port", settings["port"],
	), "%log", log,
	)
}

// Fetch activities from DB
func search_activities(s string, w http.ResponseWriter, params map[string]string) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if (params["username"] != "" && params["password"] != "") || params["api_key"] != "" {
		// auth
		if params["api_key"] != "" {
			// api_key
			fmt.Fprint(w, `api keys is not allowed`)
		} else {
			// username and password
			usr, _ := url.QueryUnescape(params["username"])
			res := userdb.SearchUser(usr)

			if len(res) > 0 {
				m := res[0]

				dbpwd := m.Password
				usrpwd := params["password"]

				hash := sha256.New()
				hash.Write([]byte(usrpwd))
				hs := hash.Sum(nil)

				dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

				if dec == dbpwd {
					query, _ := url.QueryUnescape(params["q"])
					query = strings.ToLower(query)
					town, _ := url.QueryUnescape(params["town"])
					town = strings.ToLower(town)

					res, err := userdb.SearchPlaces(query, town)

					if err != nil {
						fmt.Fprint(w, `server error`)
						Log(err.Error())
					}

					json, err := json.Marshal(res)

					if err != nil {
						fmt.Fprint(w, `server error`)
						Log(err.Error())
					}

					fmt.Fprint(w, string(json))
				} else {
					fmt.Fprint(w, `invalid password`)
				}
			} else {
				fmt.Fprint(w, `user not exists`)
			}
		}
	}
}

// Remove dublicated values from arr (string)
func removeDuplicates(arr []string) []string {
	resultMap := make(map[string]bool)
	result := []string{}

	for _, num := range arr {
		if !resultMap[num] {
			resultMap[num] = true
			result = append(result, num)
		}
	}

	return result
}

// Prepare keywords for search
func prep_keys(in string) string {
	s := strings.Split(in, " ")
	ret := ""

	for si := 0; si < len(s); si++ {
		sp := strings.Split(s[si], "")
		prev := ""

		for i := 0; i < len(sp); i++ {
			prev += sp[i]
			ret += prev + " "
		}
	}

	ret2 := strings.Split(ret, " ")
	ret = strings.Join(removeDuplicates(ret2), " ")

	return ret
}

// Add a new review to DB
func addReview(params map[string]string, w http.ResponseWriter) {
	var username = params["username"]
	var password = params["password"]
	var place_id = params["placeid"]
	var stars = params["stars"]
	var text = params["text"]

	if username != "" && password != "" && place_id != "" && stars != "" && text != "" {
		usr, _ := url.QueryUnescape(username)
		res := userdb.SearchUser(usr)

		if len(res) > 0 {
			dbpwd := res[0].Password
			usrpwd := password

			hash := sha256.New()
			hash.Write([]byte(usrpwd))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

			stars_p, err := strconv.Atoi(stars)
			if err != nil {
				fmt.Fprint(w, `400 bad request`)
			}

			placeid_p, err := strconv.Atoi(place_id)
			if err != nil {
				fmt.Fprint(w, `400 bad request`)
			}

			if dec == dbpwd {
				if userdb.InsertReview(userdb.Review{
					Placeid: placeid_p,
					Stars:   stars_p,
					Text:    text,
					Owner:   usr,
				}) {
					fmt.Fprint(w, "success")
				} else {
					fmt.Fprint(w, "500 server error")
				}
			} else {
				fmt.Fprint(w, `invalid password`)
			}
		}
	} else {
		fmt.Fprint(w, `400 bad request`)
	}
}

// Fetch all reviews from DB
func getReviews(params map[string]string, w http.ResponseWriter) {
	var username = params["username"]
	var password = params["password"]
	var place_id = params["placeid"]

	if username != "" && password != "" && place_id != "" {
		usr, _ := url.QueryUnescape(username)
		res := userdb.SearchUser(usr)

		if len(res) > 0 {
			dbpwd := res[0].Password
			usrpwd := password

			hash := sha256.New()
			hash.Write([]byte(usrpwd))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

			if dec == dbpwd {
				placeid_p, err := strconv.Atoi(place_id)
				if err != nil {
					fmt.Fprint(w, `400 bad request`)
					return
				}

				reviews, err := userdb.SearchReviews(placeid_p)

				if err != nil {
					fmt.Fprint(w, `500 server error`)
					Log(err.Error())
				}

				json, err := json.Marshal(reviews)

				if err != nil {
					fmt.Fprint(w, `500 server error`)
					Log(err.Error())
				}

				w.Header().Add("Content-Type", "application/json")
				fmt.Fprint(w, string(json))
			} else {
				fmt.Fprint(w, "invalid password")
			}
		}
	} else {
		fmt.Fprint(w, "400 bad request")
	}
}

// Fetch review from DB
func getReview(params map[string]string, w http.ResponseWriter) {
	var username = params["username"]
	var password = params["password"]
	var id = params["id"]

	if username != "" && password != "" && id != "" {
		usr, _ := url.QueryUnescape(username)
		res := userdb.SearchUser(usr)

		if len(res) > 0 {
			dbpwd := res[0].Password
			usrpwd := password

			hash := sha256.New()
			hash.Write([]byte(usrpwd))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

			if dec == dbpwd {
				id_p, err := strconv.Atoi(id)
				if err != nil {
					fmt.Fprint(w, `400 bad request`)
					return
				}

				review, err := userdb.SearchReview(id_p)

				if err != nil {
					fmt.Fprint(w, `server error`)
					return
				}

				json, err := json.Marshal(review)

				if err != nil {
					fmt.Fprint(w, `server error`)
					Log(err.Error())
					return
				}

				w.Header().Add("Content-Type", "application/json")
				fmt.Fprint(w, string(json))
			} else {
				fmt.Fprint(w, "invalid password")
			}
		}
	} else {
		fmt.Fprint(w, "400 bad request")
	}
}

// Delete review from DB
func deleteReview(params map[string]string, w http.ResponseWriter) {
	var username = params["username"]
	var password = params["password"]
	var id = params["id"]

	if username != "" && password != "" && id != "" {
		usr, _ := url.QueryUnescape(username)
		res := userdb.SearchUser(usr)

		if len(res) > 0 {
			dbpwd := res[0].Password
			usrpwd := password

			hash := sha256.New()
			hash.Write([]byte(usrpwd))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

			if dec == dbpwd {
				id_p, err := strconv.Atoi(id)
				if err != nil {
					fmt.Fprint(w, `400 bad request`)
					return
				}

				r, err := userdb.SearchReview(id_p)

				if err != nil {
					fmt.Fprint(w, "review not found")
				}
				if r.Owner == usr {
					err = userdb.DeleteReview(id_p)

					if err != nil {
						fmt.Fprint(w, `server error`)
						Log(err.Error())
						return
					}

					fmt.Fprint(w, "success")
				} else {
					fmt.Fprint(w, "review is not of user")
				}
			}
		}
	}
}

// Fetch username from db
func getUsername(params map[string]string, w http.ResponseWriter) {
	var username = params["username"]

	if username != "" {
		usr, _ := url.QueryUnescape(username)
		res := userdb.SearchUser(usr)

		if len(res) > 0 {
			w.Header().Add("Content-Type", "application/json")
			fmt.Fprint(w, `{"username": "`+res[0].Name+`"}`)
		} else {
			fmt.Fprint(w, "user not found")
		}
	}
}

// Stories recomendations algoritm
func get_user_stories(params map[string]string, w http.ResponseWriter) {
	stories, err := userdb.SearchUserStories(params["username"])

	w.Header().Set("Content-Type", "application/json")

	if err != nil {
		fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
		Log("Server error: " + err.Error())
		return
	}

	fmt.Fprint(w, stories)
}

func add_story(r *http.Request, w http.ResponseWriter) {
	println("Adding story")

	if r.FormValue("username") == "" ||
		r.FormValue("visibility") == "" ||
		r.FormValue("text") == "" ||
		r.FormValue("password") == "" {
		fmt.Fprint(w, `{"status":"error", "code":"400 bad request"}`)
		return
	}

	println("Auth")
	// Auth
	dbpwd := userdb.SearchUser(r.FormValue("username"))[0].Password
	hash := sha256.New()
	hash.Write([]byte(r.FormValue("password")))
	hs := hash.Sum(nil)
	dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))
	if dec != dbpwd {
		fmt.Fprint(w, `{"status":"error", "code":"400 bad request"}`)
		return
	}

	println("Video")
	// Read video file
	videoFile, _, err := r.FormFile("video")

	var buf bytes.Buffer
	if err != nil {
		fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
		Log("Server error: " + err.Error())
		return
	}
	defer videoFile.Close()

	println("Write")
	// Write file
	name := strings.ReplaceAll(time.Now().Format(time.DateTime), ":", "-")

	io.Copy(&buf, videoFile)
	err = os.WriteFile("./pages/video/"+name+".mp4", buf.Bytes(), 0644)
	if err != nil {
		fmt.Fprint(w, `{"status":"error", "code":"500 server error"}`)
		Log("Server error: " + err.Error())
		return
	}
	buf.Reset()

	println("Insert")
	// Insert story
	userdb.InsertStory(userdb.Story{
		Owner:      r.FormValue("username"),
		Visibility: r.FormValue("visibility"),
		Text:       r.FormValue("text"),
		VideoPath:  "video/" + name + ".mp4",
	})

	fmt.Fprint(w, `{"status":"success"}`)
}

// Guess responce method and call it
func get(s string, params map[string]string, w http.ResponseWriter, r *http.Request, settings map[string]string) {
	without_suff, _ := strings.CutSuffix(s, "/")
	without_pref, _ := strings.CutPrefix(without_suff, "/")
	pathnames := strings.Split(without_pref, "/")

	switch pathnames[0] {
	case "api":
		if len(pathnames) > 2 {
			switch pathnames[1] {
			case "v1":
				switch pathnames[2] {
				// db:users
				case "register":
					register(params, w)
				case "login":
					login(params, w)
				case "get_username":
					getUsername(params, w)
				// db:users
				case "create_travel":
					createTravel(params, w)
				case "get_all_travels":
					getAllTravels(params, w)
				case "get_travel":
					getTravel(params, w)
				case "edit_travel":
					editTravel(params, w)
				case "delete_travel":
					deleteTravel(params, w)
				// db:reviews
				case "add_review":
					addReview(params, w)
				case "get_reviews":
					getReviews(params, w)
				case "delete_review":
					deleteReview(params, w)
				case "get_review":
					getReview(params, w)
				// db:stories
				case "get_stories":
					get_user_stories(params, w)
				default:
					fmt.Fprint(w, "method not found")
				}
			case "activities":
				switch pathnames[2] {
				case "search":
					search_activities(s, w, params)
				case "insert":
					name := params["name"]
					town := strings.ToLower(params["town"])
					desc := params["desc"]
					addr := params["addr"]
					keys := params["keys"]

					if name != "" && town != "" && desc != "" && addr != "" {
						userdb.InsertPlace(userdb.Place{
							Name:        name,
							Town:        town,
							Description: desc,
							Lan:         "0",
							Lot:         "0",
							Address:     addr,
							Images:      "[]",
							Schedule:    `{"Mon": {"from": "00:00", "to": "24:00"}, "Tue": {"from": "00:00", "to": "24:00"}, "Wed": {"from": "00:00", "to": "24:00"},  "Thu": {"from": "00:00", "to": "24:00"}, "Fri": {"from": "00:00", "to": "24:00"}, "Sat": {"from": "00:00", "to": "24:00"}, "Sun": {"from": "00:00", "to": "24:00"}}`,
							Keys:        prep_keys(keys),
						})
						default_get(params, w, r, settings, "/activsadd")
					} else {
						m, _ := json.Marshal(params)
						fmt.Fprint(w, "bad request. \n <h1>Попробуйте снова</h1> <p>"+string(m)+"</p>")
					}
				}
			default:
				fmt.Fprint(w, "method not found")
			}
		} else {
			fmt.Fprint(w, "method not found")
		}
	case "admins":
		admins(params, w, r, settings)
	default:
		default_get(params, w, r, settings, s)
	}
}

func post(s string, w http.ResponseWriter, r *http.Request, settings map[string]string) {
	without_suff, _ := strings.CutSuffix(s, "/")
	without_pref, _ := strings.CutPrefix(without_suff, "/")
	pathnames := strings.Split(without_pref, "/")

	r.ParseMultipartForm(32 << 20)

	if len(pathnames) > 2 {
		switch pathnames[0] {
		case "api":
			switch pathnames[1] {
			case "v1":
				switch pathnames[2] {
				case "add_story":
					add_story(r, w)
				}
			}
		}
	}
}

// Run main function
func runserver() {
	logger.Println("-----------------" + time.Now().Format(time.DateOnly) + "--------------")
	settings := ReadSettings()

	Log("Starting HTTP server on " + string(settings["port"]))
	encode_key = string(settings["encode_key"])

	userdb.Init(logger)

	go func() {
		for {
			Log("Clearing old travels")
			clearTravels()
			time.Sleep(time.Hour * 12)
		}
	}()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		var s, _ = url.QueryUnescape(r.URL.Path)
		var q, _ = url.QueryUnescape(r.URL.RawQuery)

		var params map[string]string
		if len(q) > 0 {
			var params_ = strings.Split(q, "&")
			params = map[string]string{}

			for _, v := range params_ {
				var s = strings.Split(v, "=")
				if len(s) >= 2 {
					params[s[0]] = s[1]
				} else {
					Log("Error: bad query (" + v + ")")
				}

			}
		}

		// If request type == GET
		if r.Method == "GET" {
			get(s, params, w, r, settings)
		} else if r.Method == "POST" {
			post(s, w, r, settings)
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

func printhelp() {
	fmt.Println(`
	Travel Manager Server - help

	Run without arguments to start the server

	help, -h, --help:
		Show this message

	run, start, runserver, startserver:
		Start the server
	`)
}

func check() {
	fmt.Println("Travel Manager Server - checking")

	settings := ReadSettings()
	module_server_port := settings["module_server_port"]
	module_server_address := settings["module_server_address"]

	// Ping server
	resp, err := http.Get("http://" + module_server_address + ":" + module_server_port)

	if err != nil {
		fmt.Println("Error (while pinging module server): " + err.Error())
		return
	}

	if resp.StatusCode != 200 {
		fmt.Println("Error (while pinging module server): " + resp.Status)
		return
	}

	fmt.Println("Module server state: ok")

	// Ping database
	userdb.Init(logger)

	if err = userdb.Db.Ping(); err != nil {
		fmt.Println("Error (while pinging database): " + err.Error())
		return
	}

	fmt.Println("Database state: ok")

	fmt.Println("All services OK")
}

func main() {
	args := os.Args

	if len(args) > 1 {
		switch args[1] {
		case "help", "-h", "--help":
			printhelp()
		case "run", "start", "runserver", "startserver":
			runserver()
		case "check":
			check()
		default:
			printhelp()
		}
	} else {
		runserver()
	}
}
