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
var log_file, _ = os.OpenFile(fmt.Sprintf("logs/log-%d-%d-%d.log", log.LUTC, log.Ldate, log.Ltime), os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
var logger = log.New(io.Writer(log_file), "", 0)

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
			uuid, err_ := userdb.CreateSession(res)

			if err_ {
				fmt.Fprint(w, `{"status":"success", "session":"`+uuid+`", "name": "`+res2+`", "subscribe": "notsub"}`)
			} else {
				fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
			}
		} else {
			fmt.Fprint(w, `{"status":"error", "code":"user_exists"}`)
		}
	} else {
		fmt.Fprint(w, `{"status": "error", "code":"bad_request"}`)
	}
}

// Login user
func login(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["username"] != "" && params["password"] != "" {
		r, _ := url.QueryUnescape(params["username"])
		res := userdb.SearchUser(r)

		if len(res) > 0 {
			database_password := getFieldString(&res[0], "Password")
			user_password := params["password"]

			hash := sha256.New()
			hash.Write([]byte(user_password))
			hs := hash.Sum(nil)

			dec := EncryptAES([]byte(encode_key), hex.EncodeToString(hs))

			if dec == database_password {
				sessions, err := userdb.GetSessions(res[0].Id)
				var uuid string
				var err_ = true

				if err != nil {
					fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
					return
				}

				if len(sessions) > 0 { // "895765db-edfb-48a0-9868-47e6aca900ce"
					uuid = sessions[0]
					err_ = userdb.UpdateSession(uuid)
				} else {
					uuid, err_ = userdb.CreateSession(res[0].Email)
				}

				if !err_ {
					fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
					return
				}

				fmt.Fprint(w, `{"status":"success", "name":"`+getFieldString(&res[0], "Name")+`", "subscribe":"`+getFieldString(&res[0], "Subscribe")+`", "session":"`+uuid+`"}`)
			} else {
				fmt.Fprint(w, `{"status":"error", "code":"invalid_password"}`)
			}
		} else {
			fmt.Fprint(w, `{"status": "error", "code":"user_not_exists"}`)
		}
	} else {
		fmt.Fprint(w, `{"status": "error", "code":"bad_request"}`)
	}
}

// Create plan in DB
func createTravel(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["session"] != "" &&
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

		session, _ := url.QueryUnescape(params["session"])
		res, err := logInBySession(session)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		if (userdb.InsertPlan(
			userdb.Travel{
				Owner:       res.Email,
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
			fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
		}

	} else {
		fmt.Fprint(w, `{"status": "error", "code":"bad_request"}`)
	}
}

// Fetch all travels
func getAllTravels(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["session"] != "" {
		r, _ := url.QueryUnescape(params["session"])
		res, err := logInBySession(r)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		travels, err := userdb.SearchAllPlans(res.Email)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
			Log("Server error") // debug
			return
		}

		j, err := json.Marshal(travels)
		if err != nil {
			Log("Server error") // debug
			fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
			return
		}

		fmt.Fprint(w, `{"status":"success", "content":`+string(j)+`}`)
	} else {
		fmt.Fprint(w, `{"status": "error", "code":"bad_request"}`)
	}
}

// Fetch travel plan from db
func getTravel(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["session"] != "" && params["id"] != "" {
		r, _ := url.QueryUnescape(params["session"])
		res, err := logInBySession(r)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		id, _ := strconv.Atoi(params["id"])
		travel, err := userdb.SearchPlan(id, res.Email)
		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
			return
		}

		j, err := json.Marshal(travel)
		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
			return
		}

		fmt.Fprint(w, `{"status":"success", "content":`+string(j)+`}`)
	} else {
		fmt.Fprint(w, `{"status": "error", "code":"bad_request"}`)
	}
}

// Edit travel in DB
func editTravel(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	session := params["session"]
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

	if session != "" && planName != "" && activities != "" &&
		fromDate != "" && toDate != "" && livePlace != "" && budget != "" &&
		expenses != "" && peopleCount != "" && meta != "" && town != "" && id != "" {
		sess, _ := url.QueryUnescape(session)
		res, err := logInBySession(sess)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		if userdb.EditTravel(userdb.Travel{
			Id:          id,
			Owner:       res.Email,
			Plan_name:   planName,
			Activities:  activities,
			From_date:   fromDate,
			To_date:     toDate,
			Live_place:  livePlace,
			Budget:      budget,
			Expenses:    expenses,
			PeopleCount: peopleCount,
			Meta:        meta,
			Town:        town,
		}) {
			fmt.Fprint(w, `{"status":"success"}`)
		} else {
			fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
		}

	} else {
		fmt.Fprint(w, `{"status": "error", "code":"bad_request"}`)
	}
}

// Delete travel plan from DB
func deleteTravel(params map[string]string, w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["id"] != "" && params["session"] != "" {
		session, _ := url.QueryUnescape(params["session"])
		res, err := logInBySession(session)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		tid, _ := strconv.Atoi(params["id"])

		if userdb.DeleteTravel(tid, res.Email) {
			fmt.Fprint(w, `{"status":"success"}`)
		} else {
			fmt.Fprint(w, `{"status": "error", "code":"server_error"}`)
		}

	} else {
		fmt.Fprint(w, `{"status": "error", "code":"bad_request"}`)
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

func logInBySession(session string) (userdb.User, error) {
	user, err := userdb.SearchUserBySession(session)

	return user, err
}

// Default HTTP get
func default_get(w http.ResponseWriter, s string) {
	var err error
	var b []byte

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
	media_type := http.DetectContentType(b)
	w.Header().Set("Content-Type", media_type)

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
		var activities string
		var from_date string
		var to_date string
		var live_place string
		var budget string
		var expenses string
		var meta string
		var town string
		var people_count string

		err = rows.Scan(&id, &owner, &name, &activities, &from_date, &to_date, &live_place, &budget, &expenses, &meta, &town, &people_count)

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
func search_activities(w http.ResponseWriter, params map[string]string) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if params["session"] != "" && params["q"] != "" && params["town"] != "" {

		// ! Types
		// ! food
		// ! attraction
		// ! housing
		// ! new
		// ! event
		// ! all

		session, _ := url.QueryUnescape(params["session"])
		_, err := logInBySession(session)

		if err == nil {
			query, _ := url.QueryUnescape(params["q"])
			query = strings.ToLower(query)
			town, _ := url.QueryUnescape(params["town"])
			town = strings.ToLower(town)

			s_type := params["type"]
			if s_type == "" {
				s_type = "all"
			}

			res, err := userdb.SearchPlaces(query, town, s_type)

			if err != nil {
				fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
				Log(err.Error())
			}

			json, err := json.Marshal(res)

			if err != nil {
				fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
				Log(err.Error())
			}

			fmt.Fprint(w, `{"status":"success", "content":`+string(json)+`}`)
		} else {
			fmt.Fprint(w, `{"status": "error", "code": "user_not_exists"}`)
		}
	} else {
		fmt.Fprint(w, `{"status": "error", "code": "missing_params"}`)
	}
}

// Remove duplicated values from arr (string)
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
	var session = params["session"]
	var place_id = params["id"]
	var stars = params["stars"]
	var text = params["text"]

	if session != "" && place_id != "" && stars != "" && text != "" {
		sess, _ := url.QueryUnescape(session)
		res, err := logInBySession(sess)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		stars_p, err := strconv.Atoi(stars)
		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code": "bad_request"}`)
		}

		place_id_p, err := strconv.Atoi(place_id)
		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code": "bad_request"}`)
		}

		if userdb.InsertReview(userdb.Review{
			Placeid: place_id_p,
			Stars:   stars_p,
			Text:    text,
			Owner:   res.Email,
		}) {
			fmt.Fprint(w, `{"status":"success"`)
		} else {
			fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
		}

	} else {
		fmt.Fprint(w, `{"status":"error", "code":"bad_request"}`)
	}
}

// Fetch all reviews from DB
func getReviews(params map[string]string, w http.ResponseWriter) {
	w.Header().Add("Content-Type", "application/json")

	var session = params["session"]
	var place_id = params["place_id"]

	if session != "" && place_id != "" {
		sess, _ := url.QueryUnescape(session)
		_, err := logInBySession(sess)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		place_id_p, err := strconv.Atoi(place_id)
		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code": "bad_request"}`)
			return
		}

		reviews, err := userdb.SearchReviews(place_id_p)

		if err != nil {
			fmt.Fprint(w, `server_error`)
			Log(err.Error())
		}

		json, err := json.Marshal(reviews)

		if err != nil {
			fmt.Fprint(w, `server_error`)
			Log(err.Error())
		}

		fmt.Fprint(w, `{"status":"success", "content":`+string(json)+`}`)

	} else {
		fmt.Fprint(w, `{"status": "error", "code": "bad_request"}`)
	}
}

// Fetch review from DB
func getReview(params map[string]string, w http.ResponseWriter) {
	w.Header().Add("Content-Type", "application/json")

	var session = params["session"]
	var id = params["id"]

	if session != "" && id != "" {
		sess, _ := url.QueryUnescape(session)
		_, err := logInBySession(sess)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		id_p, err := strconv.Atoi(id)
		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code": "bad_request"}`)
			return
		}

		review, err := userdb.SearchReview(id_p)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code": "server_error"}`)
			return
		}

		json, err := json.Marshal(review)

		if err != nil {
			fmt.Fprint(w, `{"status": "error", "code": "server_error"}`)
			Log(err.Error())
			return
		}

		fmt.Fprint(w, `{"status":"success", "content":`+string(json)+`}`)
	} else {
		fmt.Fprint(w, `{"status":"error", "code": "bad_request"}`)
	}
}

// Delete review from DB
func deleteReview(params map[string]string, w http.ResponseWriter) {
	var session = params["session"]
	var id = params["id"]

	if session != "" && id != "" {
		sess, _ := url.QueryUnescape(session)
		res, err := logInBySession(sess)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		id_p, err := strconv.Atoi(id)
		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code": "bad_request"}`)
			return
		}

		r, err := userdb.SearchReview(id_p)

		if err != nil {
			fmt.Fprint(w, "review not found")
		}
		if r.Owner == res.Email {
			err = userdb.DeleteReview(id_p)

			if err != nil {
				fmt.Fprint(w, `{"status":"error", "code":"server_error"}`)
				Log(err.Error())
				return
			}

			fmt.Fprint(w, `{"status":"success"}`)
		} else {
			fmt.Fprint(w, `{"status": "error", "code": "not_your_review"}`)
		}

	}
}

// Fetch username from db
func getUsername(params map[string]string, w http.ResponseWriter) {
	w.Header().Add("Content-Type", "application/json")

	var session = params["session"]
	var otherUsername = params["other_user"]

	if session != "" {
		sess, _ := url.QueryUnescape(session)
		_, err := logInBySession(sess)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		user := userdb.SearchUser(otherUsername)

		if len(user) > 0 {
			fmt.Fprint(w, `{"status":"success", "name": "`+user[0].Name+`"}`)
		} else {
			fmt.Fprint(w, `{"status":"error", "code": "user_not_found"}`)
		}
	}
}

func checkSession(params map[string]string, w http.ResponseWriter) {
	w.Header().Add("Content-Type", "application/json")

	var session, err = url.QueryUnescape(params["session"])

	if session != "" && err == nil {
		user, err := logInBySession(session)

		if err != nil {
			fmt.Fprint(w, `{"status":"error", "code":"session_not_exists"}`)
			return
		}

		fmt.Fprint(w, `{"status":"success", "name": "`+user.Name+`", "subscribe": "`+user.Subscribe+`"}`)
	} else {
		fmt.Fprint(w, `{"status":"error", "code": "bad_request"}`)
	}
}

func logout(params map[string]string, w http.ResponseWriter) {
	w.Header().Add("Content-Type", "application/json")

	var session = params["session"]

	if session != "" {
		sess, _ := url.QueryUnescape(session)
		userdb.DeleteSession(sess)
		fmt.Fprint(w, `{"status":"success"}`)
	} else {
		fmt.Fprint(w, `{"status":"error", "code": "bad_request"}`)
	}
}

// Guess response method and call it
func get(s string, params map[string]string, w http.ResponseWriter, r *http.Request, settings map[string]string) {
	without_suffix, _ := strings.CutSuffix(s, "/")
	without_pref, _ := strings.CutPrefix(without_suffix, "/")
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
				// db:sessions
				case "check_session":
					checkSession(params, w)
				case "logout":
					logout(params, w)
				default:
					fmt.Fprint(w, "method not found 3")
				}
			case "activities":
				switch pathnames[2] {
				case "search":
					search_activities(w, params)
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
						default_get(w, "/activsadd")
					} else {
						m, _ := json.Marshal(params)
						fmt.Fprint(w, "bad request. \n <h1>Попробуйте снова</h1> <p>"+string(m)+"</p>")
					}
				default:
					fmt.Fprint(w, "method not found 1")
				}

			default:
				fmt.Fprint(w, "method not found 2")
			}
		} else {
			fmt.Fprint(w, "method not found")
		}
	case "admins":
		admins(params, w, r, settings)
	default:
		default_get(w, s)
	}
}

func post(s string, w http.ResponseWriter, r *http.Request) {
	without_suffix, _ := strings.CutSuffix(s, "/")
	without_pref, _ := strings.CutPrefix(without_suffix, "/")
	pathnames := strings.Split(without_pref, "/")

	r.ParseMultipartForm(32 << 20)

	if len(pathnames) > 2 {
		switch pathnames[0] {
		case "api":
			switch pathnames[1] {
			case "v1":
				switch pathnames[2] {
				// case "add_story":
				// 	add_story(r, w)
				default:
					fmt.Fprint(w, `{"status":"error", "code":"method_not_found"}`)
				}
			}
		}
	}
}

// Run main function
func run_server() {
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

	// go func() {
	// 	for {
	// 		Log("Clearing old sessions")
	// 		time.Sleep(time.Hour * 24 * 14)
	// 	}
	// }()

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
			post(s, w, r)
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

func print_help() {
	fmt.Println(`
	Travel Manager Server - help

	Run without arguments to start the server

	help, -h, --help:
		Show this message

	run, start, run_server, startserver:
		Start the server
	`)
}

func print_methods() {
	fmt.Println(`
	Methods (by HTTP):

	
	`)
}

func main() {
	args := os.Args

	if len(args) > 1 {
		switch args[1] {
		case "help", "-h", "--help":
			print_help()
		case "run", "start", "run_server", "startserver":
			run_server()
		case "methods", "-m", "--methods":
			print_methods()
		default:
			fmt.Println("	Unknown command: " + args[1])
			print_help()
		}
	} else {
		run_server()
	}
}
