package handler

import (
	"crypto/aes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"reflect"
	"strings"
	"time"

	"net/http"
	"net/url"
	"strconv"
	userdb "travel_server/src/db"
	resp "travel_server/src/responses"
)

var encode_key string
var logger *log.Logger

func SetEncodeKey(key string) {
    encode_key = key
}

func SetLogger(l *log.Logger) {
    logger = l
}

// Print log
func Log(toLog string) {
	logger.Println(toLog)
	log.Default().Println(toLog)
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

// check if all parameters from map[string]string are set
func checkParams(params map[string]string, required []string) bool {
	for _, v := range required {
		if params[v] == "" {
			return false
		}
	}
	return true
}

// get string from field
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

// Log-ins by session id
func logInBySession(session string) (userdb.User, error) {
	user, err := userdb.SearchUserBySession(session)
	return user, err
}

// Create user
func register(params map[string]string, w http.ResponseWriter) {
	if checkParams(params, []string{"username", "password", "name"}) {
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
				resp.Success(w, `{"session": "`+uuid+`", "name": "`+res2+`", "subscribe": "notsub"}`)
			} else {
				resp.ServerError(w)
			}
		} else {
			resp.UserExists(w)
		}
	} else {
		resp.BadRequest(w)
	}
}

// Login user
func login(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"username", "password"}) {

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
					resp.ServerError(w)
					return
				}

				if len(sessions) > 0 {
					uuid = sessions[0]
					err_ = userdb.UpdateSession(uuid)
				} else {
					uuid, err_ = userdb.CreateSession(res[0].Email)
				}

				if !err_ {
					resp.ServerError(w)
					return
				}

				resp.Success(w, `{"session": "`+uuid+`", "name": "`+getFieldString(&res[0], "Name")+`", "subscribe": "`+getFieldString(&res[0], "Subscribe")+`"}`)
			} else {
				resp.InvalidPassword(w)
			}
		} else {
			resp.UserNotExists(w)
		}
	} else {
		resp.BadRequest(w)
	}
}

// Create plan in DB
func createTravel(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session", "plan_name", "activities", "from_date", "to_date", "live_place", "budget", "expenses", "people_count", "meta", "town"}) {

		session, _ := url.QueryUnescape(params["session"])
		res, err := logInBySession(session)

		if err != nil {
			resp.SessionNotExists(w)
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
			resp.Success(w, "{}")
		} else {
			resp.ServerError(w)
		}

	} else {
		resp.BadRequest(w)
	}
}

// Fetch all travels
func getAllTravels(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session"}) {

		r, _ := url.QueryUnescape(params["session"])
		res, err := logInBySession(r)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		travels, err := userdb.SearchAllPlans(res.Email)

		if err != nil {
			resp.ServerError(w)

			Log("Server error")
			Log(err.Error())

			return
		}

		j, err := json.Marshal(travels)
		if err != nil {
			resp.ServerError(w)

			Log("Server error")
			Log(err.Error())

			return
		}

		resp.Success(w, string(j))
	} else {
		resp.BadRequest(w)
	}
}

// Fetch travel plan from db
func getTravel(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session", "id"}) {

		r, _ := url.QueryUnescape(params["session"])
		res, err := logInBySession(r)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		id, _ := strconv.Atoi(params["id"])
		travel, err := userdb.SearchPlan(id, res.Email)
		if err != nil {
			resp.ServerError(w)
			return
		}

		j, err := json.Marshal(travel)
		if err != nil {
			resp.ServerError(w)
			return
		}

		resp.Success(w, string(j))
	} else {
		resp.BadRequest(w)
	}
}

// Edit travel in DB
func editTravel(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session", "plan_name", "activities", "from_date", "to_date", "live_place", "budget", "expenses", "people_count", "meta", "town", "id"}) {

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

		sess, _ := url.QueryUnescape(session)
		res, err := logInBySession(sess)

		if err != nil {
			resp.SessionNotExists(w)
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
			resp.Success(w, "{}")
		} else {
			resp.ServerError(w)
		}

	} else {
		resp.BadRequest(w)
	}
}

// Delete travel plan from DB
func deleteTravel(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session", "id"}) {

		session, _ := url.QueryUnescape(params["session"])
		res, err := logInBySession(session)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		tid, _ := strconv.Atoi(params["id"])

		if userdb.DeleteTravel(tid, res.Email) {
			resp.Success(w, "{}")
		} else {
			resp.ServerError(w)
		}

	} else {
		resp.BadRequest(w)
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
func ClearTravels() {
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

	if checkParams(params, []string{"session", "q", "town"}) {

		// Types
		// food
		// attraction
		// housing
		// new
		// event
		// all

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
				resp.ServerError(w)
				Log(err.Error())
			}

			json, err := json.Marshal(res)

			if err != nil {
				resp.ServerError(w)
				Log(err.Error())
			}

			resp.Success(w, string(json))
		} else {
			resp.SessionNotExists(w)
		}
	} else {
		resp.BadRequest(w)
	}
}

// Add a new review to DB
func addReview(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session", "id", "stars", "text"}) {

		session := params["session"]
		place_id := params["id"]
		stars := params["stars"]
		text := params["text"]

		sess, _ := url.QueryUnescape(session)
		res, err := logInBySession(sess)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		stars_p, err := strconv.Atoi(stars)
		if err != nil {
			resp.BadRequest(w)
		}

		place_id_p, err := strconv.Atoi(place_id)
		if err != nil {
			resp.BadRequest(w)
		}

		if userdb.InsertReview(userdb.Review{
			Placeid: place_id_p,
			Stars:   stars_p,
			Text:    text,
			Owner:   res.Email,
		}) {
			resp.Success(w, "{}")
		} else {
			resp.ServerError(w)
		}

	} else {
		resp.BadRequest(w)
	}
}

// Fetch all reviews from DB
func getReviews(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session", "place_id"}) {

		var session = params["session"]
		var place_id = params["place_id"]

		sess, _ := url.QueryUnescape(session)
		_, err := logInBySession(sess)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		place_id_p, err := strconv.Atoi(place_id)
		if err != nil {
			resp.BadRequest(w)
			return
		}

		reviews, err := userdb.SearchReviews(place_id_p)

		if err != nil {
			resp.ServerError(w)
			Log(err.Error())
		}

		json, err := json.Marshal(reviews)

		if err != nil {
			resp.ServerError(w)
			Log(err.Error())
		}

		resp.Success(w, string(json))

	} else {
		resp.BadRequest(w)
	}
}

// Fetch review from DB
func getReview(params map[string]string, w http.ResponseWriter) {
	if checkParams(params, []string{"session", "id"}) {
		var session = params["session"]
		var id = params["id"]

		sess, _ := url.QueryUnescape(session)
		_, err := logInBySession(sess)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		id_p, err := strconv.Atoi(id)
		if err != nil {
			resp.BadRequest(w)
			return
		}

		review, err := userdb.SearchReview(id_p)

		if err != nil {
			resp.ServerError(w)

			Log(err.Error())
			return
		}

		json, err := json.Marshal(review)

		if err != nil {
			resp.ServerError(w)

			Log(err.Error())
			return
		}

		resp.Success(w, string(json))
	} else {
		resp.BadRequest(w)
	}
}

// Delete review from DB
func deleteReview(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session", "id"}) {

		var session = params["session"]
		var id = params["id"]

		sess, _ := url.QueryUnescape(session)
		res, err := logInBySession(sess)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		id_p, err := strconv.Atoi(id)
		if err != nil {
			resp.BadRequest(w)
			return
		}

		r, err := userdb.SearchReview(id_p)

		if err != nil {
			resp.ReviewNotFound(w)
		}
		if r.Owner == res.Email {
			err = userdb.DeleteReview(id_p)

			if err != nil {
				resp.ServerError(w)

				Log(err.Error())
				return
			}

			resp.Success(w, "{}")
		} else {
			resp.NotYourReview(w)
		}

	}
}

// Fetch username from db
func getUsername(params map[string]string, w http.ResponseWriter) {
	if checkParams(params, []string{"session", "other_user"}) {
		var session = params["session"]
		var otherUsername = params["other_user"]

		sess, _ := url.QueryUnescape(session)
		_, err := logInBySession(sess)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		user := userdb.SearchUser(otherUsername)

		if len(user) > 0 {
			resp.Success(w, `{"name":"`+user[0].Name+`"}`)
		} else {
			resp.UserNotExists(w)
		}
	}
}

func checkSession(params map[string]string, w http.ResponseWriter) {
	if checkParams(params, []string{"session"}) {
		var session, err = url.QueryUnescape(params["session"])

		if err != nil {
			resp.BadRequest(w)
			return
		}

		user, err := logInBySession(session)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		resp.Success(w, `{"name":"`+user.Name+`", "subscribe": "`+user.Subscribe+`"}`)
	} else {
		resp.BadRequest(w)
	}
}

func logout(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session"}) {
		var session = params["session"]

		sess, _ := url.QueryUnescape(session)
		userdb.DeleteSession(sess)

		resp.Success(w, "{}")
	} else {
		resp.BadRequest(w)
	}
}

func searchTown(params map[string]string, w http.ResponseWriter) {

	if checkParams(params, []string{"session", "q"}) {
		var session = params["session"]
		var query = params["q"]

		sess, _ := url.QueryUnescape(session)
		_, err := logInBySession(sess)

		if err != nil {
			resp.SessionNotExists(w)
			return
		}

		towns, err := userdb.SearchTown(query)

		if err != nil {
			resp.ServerError(w)

			Log(err.Error())
			return
		}

		json, err := json.Marshal(towns)

		if err != nil {
			resp.ServerError(w)

			Log(err.Error())
			return
		}

		resp.Success(w, string(json))
	} else {
		resp.BadRequest(w)
	}
}

// on GET request
func Get(s string, params map[string]string, w http.ResponseWriter, r *http.Request, settings map[string]string) {
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
				case "search_town":
					searchTown(params, w)
				default:
					fmt.Fprint(w, "method not found")
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
					type_ := params["type"]

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
							Type:        type_,
						})
						default_get(w, "/activsadd")
					} else {
						m, _ := json.Marshal(params)
						fmt.Fprint(w, "bad request\r\n"+string(m))
					}
				default:
					fmt.Fprint(w, "method not found")
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
		default_get(w, s)
	}
}

// on POST request
func Post(s string, w http.ResponseWriter, r *http.Request) {
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
