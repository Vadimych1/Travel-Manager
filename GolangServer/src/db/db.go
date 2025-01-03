package db

import (
	"database/sql"
	"errors"
	"fmt"
	"log"

	"github.com/go-sql-driver/mysql"
	"github.com/google/uuid"
)

var Db *sql.DB

// TABLES
const (
	TABLE_ACTIVITIES string = "activities"
	TABLE_REVIEWS    string = "reviews"
	TABLE_PLANS      string = "plans"
	TABLE_USERS      string = "users"
	TABLE_STORIES    string = "stories"
	TABLE_TOWNS      string = "towns"
)

// STORY TYPES
const (
	STORY_PUBLIC       string = "public"
	STORY_FRIENDS_ONLY string = "friends_only"
	STORY_PRIVATE      string = "private"
)

// User
type User struct {
	Id        int
	Email     string
	Password  string
	Name      string
	Subscribe string
}

// Travel
type Travel struct {
	Id          string `json:"id"`
	Owner       string `json:"owner"`
	Plan_name   string `json:"plan_name"`
	Activities  string `json:"activities"`
	From_date   string `json:"from_date"`
	To_date     string `json:"to_date"`
	Live_place  string `json:"live_place"`
	Budget      string `json:"budget"`
	Expenses    string `json:"expenses"`
	PeopleCount string `json:"people_count"`
	Town        string `json:"town"`
	Meta        string `json:"meta"`
}

// Place
type Place struct {
	Id          int     `json:"id"`
	Name        string  `json:"name"`
	Town        string  `json:"town"`
	Lan         string  `json:"lan"`
	Lot         string  `json:"lot"`
	Address     string  `json:"address"`
	Images      string  `json:"images"`
	Schedule    string  `json:"schedule"`
	Description string  `json:"description"`
	Type        string  `json:"type"`
	Relev       float64 `json:"relev"`
}

// Review
type Review struct {
	Id      int    `json:"id"`
	Owner   string `json:"owner"`
	Text    string `json:"text"`
	Stars   int    `json:"stars"`
	Placeid int    `json:"placeid"`
}

type Story struct {
	Id          int    `json:"id"`
	Owner       string `json:"owner"`
	Visibility  string `json:"visibility"`
	Text        string `json:"text"`
	VideoPath   string `json:"videopath"`
	PublishDate string `json:"publish_date"`
}

type Town struct {
	Name        string  `json:"name"`
	DisplayName string  `json:"display_name"`
	Type        string  `json:"type"`
	Relev       float64 `json:"relev"`
}

var Logger *log.Logger

// Init initializes the database connection and logs the connection status.
func Init(logger *log.Logger) {
	// Set up the database configuration
	cfg := mysql.Config{
		User:   "admin",
		Passwd: "root",
		Net:    "tcp",
		Addr:   "127.0.0.1:3306",
		DBName: "travel_manager",
	}

	var err error
	// Open a connection to the database
	Db, err = sql.Open("mysql", cfg.FormatDSN())
	if err != nil {
		log.Fatal(err)
	}

	// Check if the connection is successful
	if err = Db.Ping(); err != nil {
		log.Fatal(err)
	}

	// Log the connection status
	logger.Println("Connected to database")
	log.Println("Connected to database")

	Logger = logger
}

// ! Users block
// InsertUser inserts a new user into the database.
func InsertUser(usrname string, pwd string, name string) bool {
	// Prepare the query
	query := `INSERT INTO users (email, password, name) VALUES (?, ?, ?)`

	// Execute the query with the provided parameters
	_, err := Db.Exec(query, usrname, pwd, name)
	if err != nil {
		fmt.Println(err)
		return false
	}

	return true
}

// SearchUser searches for a user in the database based on their email.
func SearchUser(email_ string) []User {
	// Print a message to indicate that the user search is being performed
	// fmt.Println("Searching user...")

	// Define the SQL query to retrieve the user with the given email
	query := "SELECT * FROM users WHERE email = ?"

	// Execute the query and store the resulting rows in the "rows" variable
	rows, err := Db.Query(query, email_)
	if err != nil {
		// Print the error if there is an issue executing the query
		fmt.Print(err)
		return nil
	}

	// Declare variables to store the values retrieved from the rows
	var id int
	var email string
	var password string
	var name string
	var subscribe string

	// Create an empty slice to store the search results
	results := []User{}

	// Iterate over the rows returned by the query
	for rows.Next() {
		// Scan the values from the rows into the respective variables
		err := rows.Scan(&id, &email, &password, &name, &subscribe)
		if err != nil {
			// Print the error if there is an issue scanning the values
			fmt.Println(err)
			continue
		}

		// Create a new User struct using the retrieved values and append it to the results slice
		results = append(results, User{Id: id, Email: email, Password: password, Name: name, Subscribe: subscribe})
	}

	// Return the search results
	return results
}

// ! Plans block
// SearchTravel searches for a travel plan with the given ID and owner.
func SearchPlan(id int, usrname string) (Travel, error) {
	fmt.Println("Searching travel...")

	// Prepare the SQL query
	query := "SELECT * FROM plans WHERE owner = ? AND id = ?"

	// Execute the query and get the row result
	row := Db.QueryRow(query, usrname, id)

	var travel Travel

	// Scan the row result into the travel struct
	err := row.Scan(
		&travel.Id,
		&travel.Owner,
		&travel.Plan_name,
		&travel.Activities,
		&travel.From_date,
		&travel.To_date,
		&travel.Live_place,
		&travel.Budget,
		&travel.Expenses,
		&travel.Meta,
		&travel.Town,
		&travel.PeopleCount,
	)

	// Handle any errors that occurred during scanning
	if err != nil {
		if err == sql.ErrNoRows {
			return Travel{}, errors.New("SearchError: plan not found")
		} else {
			Logger.Fatal(err)
			log.Fatal(err)
		}
		return Travel{}, err
	}

	// Return the found travel plan
	return travel, nil
}

// SearchAllPlans returns all travel plans owned by the given owner.
func SearchAllPlans(owner string) ([]Travel, error) {
	// Construct the SQL query
	query := "SELECT * FROM plans WHERE owner = ?"

	// Execute the query and get the result rows
	rows, err := Db.Query(query, owner)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// Create a slice to store the travel plans
	vals := []Travel{}

	// Iterate over the rows and scan the data into a Travel struct
	for rows.Next() {
		var t Travel
		err := rows.Scan(&t.Id, &t.Owner, &t.Plan_name, &t.Activities, &t.From_date, &t.To_date, &t.Live_place, &t.Budget, &t.Expenses, &t.Meta, &t.Town, &t.PeopleCount)
		if err != nil {
			return nil, err
		}
		vals = append(vals, t)
	}

	// Return the travel plans
	return vals, nil
}

// InsertPlan inserts a travel plan into the database.
func InsertPlan(plan Travel) bool {
	// Declare an error variable
	var err error

	// Define the query to insert a plan into the plans table
	query := `INSERT INTO plans 
		(owner, plan_name, activities, from_date, to_date, live_place, budget, expenses, meta, town, people_count) 
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`

	// Create a slice of interface values to hold the query arguments
	args := []interface{}{
		plan.Owner,
		plan.Plan_name,
		plan.Activities,
		plan.From_date,
		plan.To_date,
		plan.Live_place,
		plan.Budget,
		plan.Expenses,
		plan.Meta,
		plan.Town,
		plan.PeopleCount,
	}

	// If the plan has an ID, update the query and prepend the ID to the args slice
	if plan.Id != "" {
		query = `INSERT INTO plans 
			(id, owner, plan_name, activities, from_date, to_date, live_place, budget, expenses, meta, town, people_count) 
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
		args = append([]interface{}{plan.Id}, args...)
	}

	// Execute the query with the arguments and assign the result to the err variable
	_, err = Db.Exec(query, args...)

	// Print the error (if any)
	fmt.Println(err)

	// Return true if the insertion was successful, otherwise false
	return err == nil
}

// DeleteTravel deletes a travel plan from the database.
func DeleteTravel(id int, usrname string) bool {
	// Define the SQL query to delete the travel plan with the given ID and owner
	query := "DELETE FROM plans WHERE id = ? AND owner = ?"

	// Execute the SQL query and check for any errors
	_, err := Db.Exec(query, id, usrname)

	// Return true if there are no errors, indicating that the travel plan was successfully deleted
	return err == nil
}

func EditTravel(plan Travel) bool {
	var err error

	_, err = Db.Exec(`UPDATE plans SET 
	plan_name = ?, 
	activities = ?, 
	from_date = ?, 
	to_date = ?, 
	live_place = ?,
	budget = ?, 
	expenses = ?, 
	meta = ?, 
	town = ?, 
	people_count = ? WHERE id = ?`, plan.Plan_name, plan.Activities, plan.From_date, plan.To_date, plan.Live_place, plan.Budget,
		plan.Expenses, plan.Meta, plan.Town, plan.PeopleCount, plan.Id)

	return err == nil
}

// ! Places block (activities)
// InsertPlace inserts a place into the database.
func InsertPlace(activity Place) bool {
	var err error

	// SQL query to insert a new activity into the activities table
	query := `INSERT INTO activities 
	(name, town, lan, lot, adress, images, schedule, description, type) 
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`

	// Arguments for the SQL query
	args := []interface{}{
		activity.Name,
		activity.Town,
		activity.Lan,
		activity.Lot,
		activity.Address,
		activity.Images,
		activity.Schedule,
		activity.Description,
		activity.Type,
	}

	// Execute the SQL query with the arguments
	_, err = Db.Exec(query, args...)

	// Print the error
	if err != nil {
		fmt.Println(err)
	}

	// Return true if the error is nil, indicating successful insertion
	return err == nil
}

// SearchPlace retrieves a Place with the given ID from the activities table in the database.
func SearchPlace(id int) (Place, error) {
	var err error

	// SQL query to retrieve the activity with the given ID
	query := "SELECT * FROM activities WHERE id = ?"

	// Execute the SQL query
	rows, err := Db.Query(query, id)
	if err != nil {
		return Place{}, err
	}
	defer rows.Close()

	// Process the query result
	if rows.Next() {
		var activity Place
		err := rows.Scan(&activity.Id, &activity.Name, &activity.Town, &activity.Lan, &activity.Lot, &activity.Address, &activity.Images, &activity.Schedule, &activity.Description, &activity.Type)
		if err != nil {
			return Place{}, err
		}

		return activity, nil
	} else {
		return Place{}, errors.New("error: no rows found")
	}
}

// EditPlace updates the information of a Place in the database.
func EditPlace(activity Place) bool {
	var err error

	// Insert new activity
	_, err = Db.Exec(
		"UPDATE activities SET name = ?, town = ?, lan = ?, lot = ?, address = ?, images = ?, schedule = ?, description = ? WHERE id = ?",
		activity.Name,
		activity.Town,
		activity.Lan,
		activity.Lot,
		activity.Address,
		activity.Images,
		activity.Schedule,
		activity.Description,
		activity.Id,
	)

	return err == nil
}

func DeletePlace(id int) bool {
	query := "DELETE FROM activities WHERE id = ?"

	_, err := Db.Exec(query, id)

	return err == nil
}

// Search activities from table activities with given name
func SearchPlaces(query string, town string, s_type string) ([]Place, error) {
	var err error
	var rows *sql.Rows

	// fmt.Println(query, town, s_type)

	if s_type == "all" {
		rows, err = Db.Query(`SELECT *, MATCH (name) AGAINST (? IN NATURAL LANGUAGE MODE) AS relev FROM activities
		WHERE name LIKE ? AND town = ?
		ORDER BY relev DESC
		LIMIT 15`,
			"%"+query+"%",
			"%"+query+"%",
			town,
		)
	} else {
		rows, err = Db.Query(`SELECT *, MATCH (name) AGAINST (? IN NATURAL LANGUAGE MODE) AS relev FROM activities
		WHERE name LIKE ? AND town = ? AND type = ?
		ORDER BY relev DESC
		LIMIT 15`,
			"%"+query+"%",
			"%"+query+"%",
			town,
			s_type,
		)
	}

	if err != nil {
		return nil, err
	}

	var id int
	var name string
	var town_ string
	var lan string
	var lot string
	var address string
	var images string
	var schedule string
	var description string
	var type_ string
	var relev float64

	var activities = make([]Place, 0)
	for rows.Next() {
		rows.Scan(&id, &name, &town_, &lan, &lot, &address, &images, &schedule, &description, &type_, &relev)
		activities = append(activities, Place{
			Id:          id,
			Name:        name,
			Town:        town_,
			Lan:         lan,
			Lot:         lot,
			Address:     address,
			Images:      images,
			Schedule:    schedule,
			Description: description,
			Type:        type_,
			Relev:       relev,
		})
	}

	return activities, nil
}

// ! Reviews block
// InsertReview inserts a new review into the reviews table in the database.
func InsertReview(review Review) bool {
	q := fmt.Sprintf(`INSERT INTO %s (owner, text, stars, placeid) VALUES (?, ?, ?, ?)`, TABLE_REVIEWS)

	_, err := Db.Exec(q, review.Owner, review.Text, review.Stars, review.Placeid)

	return err == nil
}

func SearchReviews(placeid int) ([]Review, error) {
	rows, err := Db.Query(fmt.Sprintf(`SELECT * FROM %s WHERE placeid = ?`, TABLE_REVIEWS), placeid)

	if err != nil {
		return nil, err
	}

	var id int
	var owner string
	var text string
	var stars int
	var placeid_ int

	var reviews = make([]Review, 0)
	for rows.Next() {
		rows.Scan(&id, &owner, &text, &stars, &placeid_)
		reviews = append(reviews, Review{
			Id:      id,
			Owner:   owner,
			Text:    text,
			Stars:   stars,
			Placeid: placeid_,
		})
	}

	return reviews, nil
}

func SearchReview(id int) (Review, error) {
	var review Review
	var err = Db.QueryRow(fmt.Sprintf(`SELECT * FROM %s WHERE id = ?`, TABLE_REVIEWS), id).Scan(&review.Id, &review.Owner, &review.Text, &review.Stars, &review.Placeid)

	return review, err
}

func DeleteReview(id int) error {
	_, err := Db.Exec(fmt.Sprintf(`DELETE FROM %s WHERE id = ?`, TABLE_REVIEWS), id)
	return err
}

func EditReview(review Review) bool {
	_, err := Db.Exec(fmt.Sprintf(`UPDATE %s SET text = ?, stars = ? WHERE id = ?`, TABLE_REVIEWS), review.Text, review.Stars, review.Id)
	return err == nil
}

// ! Stories block
func InsertStory(story Story) bool {
	_, err := Db.Exec(
		fmt.Sprintf(`INSERT INTO %s (owner, visibility, text, videopath) VALUES (?, ?, ?, ?)`, TABLE_STORIES),
		story.Owner,
		story.Visibility,
		story.Text,
		story.VideoPath,
	)

	return err == nil
}

func SearchStory(id int) (Story, error) {
	var story Story
	var err = Db.QueryRow(fmt.Sprintf(`SELECT * FROM %s WHERE id = ?`, TABLE_STORIES), id).Scan(&story.Id, &story.Owner, &story.Visibility, &story.Text, &story.VideoPath)

	return story, err
}

func SearchUserStories(owner string) ([]Story, error) {
	rows, err := Db.Query(fmt.Sprintf(`SELECT * FROM %s WHERE owner = ?`, TABLE_STORIES), owner)

	if err != nil {
		return nil, err
	}

	var id int
	var owner_ string
	var visibility string
	var text string
	var videopath string
	var publish_date string

	var stories = make([]Story, 0)
	for rows.Next() {
		rows.Scan(&id, &owner_, &visibility, &text, &videopath, &publish_date)
		stories = append(stories, Story{
			Id:          id,
			Owner:       owner_,
			Visibility:  visibility,
			Text:        text,
			VideoPath:   videopath,
			PublishDate: publish_date,
		})
	}

	return stories, nil
}

func DeleteStory(id int) error {
	_, err := Db.Exec(fmt.Sprintf(`DELETE FROM %s WHERE id = ?`, TABLE_STORIES), id)
	return err
}

// ! Sessions
func CreateSession(username string) (string, bool) {
	user := SearchUser(username)

	if len(user) == 0 {
		return "", false
	}

	var err error
	var counter = 0

	var uuid_ string

	for {
		uuid_ = uuid.New().String()
		_, err = Db.Exec("INSERT INTO sessions (uuid, userid) VALUES (?, ?)", uuid_, user[0].Id)

		if err == nil {
			break
		}

		counter++
		if counter > 10 {
			return "", false
		}
	}

	return uuid_, err == nil
}

func DeleteSession(uuid string) bool {
	_, err := Db.Exec("DELETE FROM sessions WHERE uuid = ?", uuid)

	return err == nil
}

func UpdateSession(uuid string) bool {
	_, err := Db.Exec("UPDATE sessions SET last_used = NOW() WHERE uuid = ?", uuid)

	if err != nil {
		println(err.Error())
	}

	return err == nil
}

func SearchUserBySession(uuid string) (User, error) {
	var user User

	var userId int
	var lastActivity string
	var createdAt string

	var err = Db.QueryRow("SELECT userid, last_used, created FROM sessions WHERE uuid = ?", uuid).Scan(&userId, &createdAt, &lastActivity)

	if err == nil {
		var err2 = Db.QueryRow("SELECT id, email, password, name, subscribe FROM users WHERE id = ?", userId).Scan(&user.Id, &user.Email, &user.Password, &user.Name, &user.Subscribe)

		if err2 == nil {
			UpdateSession(uuid)
			return user, nil
		}
	}

	return user, err
}

func GetSessions(userid int) ([]string, error) {
	rows, err := Db.Query("SELECT uuid FROM sessions WHERE userid = ?", userid)

	if err != nil {
		return nil, err
	}

	var uuidArr = make([]string, 0)

	for rows.Next() {
		var uuid_ string
		rows.Scan(&uuid_)
		uuidArr = append(uuidArr, uuid_)
	}

	return uuidArr, nil
}

// ! Towns

// ? Town types
// ? beautiful
// ? plain
// ? regional_center
// ? resort_town

func SearchTown(query string) ([]Town, error) {
	rows, err := Db.Query("SELECT *, MATCH (name) AGAINST (? IN NATURAL LANGUAGE MODE) AS relev FROM towns WHERE name LIKE ? ORDER BY relev DESC LIMIT 10", "%"+query+"%", "%"+query+"%")

	if err != nil {
		return nil, err
	}

	var name string
	var display_name string
	var type_ string
	var relev float64

	var towns = make([]Town, 0)

	for rows.Next() {
		rows.Scan(&name, &display_name, &type_, &relev)

		towns = append(towns, Town{
			Name:        name,
			DisplayName: display_name,
			Relev:       relev,
			Type:        type_,
		})
	}

	return towns, nil
}
