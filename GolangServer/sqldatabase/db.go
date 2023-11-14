package usersdatabase

import (
	"database/sql"
	"errors"
	"fmt"
	"log"
	"reflect"

	"github.com/go-sql-driver/mysql"
)

var db *sql.DB

type User struct {
	Id       int    `json:"id"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type Travel struct {
	Id         string
	Owner      string
	Plan_name  string
	Activities string
	From_date  string
	To_date    string
	Live_place string
	Budget     string
	Expenses   string
}

func getFieldString(e *Travel, field string) string {
	r := reflect.ValueOf(e)
	f := reflect.Indirect(r).FieldByName(field)
	return f.String()
}

func Init() {
	cfg := mysql.Config{
		User:   "admin",
		Passwd: "root",
		Net:    "tcp",
		Addr:   "127.0.0.1:3306",
		DBName: "travel_manager",
	}

	var err error
	db, err = sql.Open("mysql", cfg.FormatDSN())

	if err != nil {
		log.Fatal(err)
	}

	pingErr := db.Ping()
	if pingErr != nil {
		log.Fatal(pingErr)
	}

	fmt.Print("Connected to database\n")
}

func InsertUser(usrname string, pwd string, name string) bool {
	_, err := db.Exec("INSERT INTO users (email,password,name) VALUES ('" + usrname + "','" + pwd + "','" + name + "')")

	if err != nil {
		fmt.Println(err)
		return false
	}

	// fmt.Print(res)
	return true
}

func SearchUser(usrname string) []User {
	rows, err := db.Query("SELECT * FROM users WHERE email = '" + usrname + "'")

	if err != nil {
		fmt.Print(err)
	}

	var id int
	var email string
	var password string

	results := []User{}

	for rows.Next() {
		rows.Scan(&id, &email, &password)
		results = append(results, User{Id: id, Email: email, Password: password})
	}

	return results
}

func SearchTravel(id int, usrname string) (Travel, error) {
	rows, err := db.Query("SELECT * FROM plans WHERE owner = '" + usrname + "' AND id = " + fmt.Sprint(id))

	if err != nil {
		return Travel{}, err
	}

	var p_id int
	var p_owner string
	var plan_name string
	var activities string
	var from_date string
	var to_date string
	var live_place string
	var budget int
	var expenses string

	if rows.Next() {
		rows.Scan(&p_id, &p_owner, &plan_name, &activities, &from_date, &to_date, &live_place, &budget, &expenses)
	} else {
		return Travel{}, errors.New("SearchError: plan not found")
	}

	return Travel{
		Id:         fmt.Sprint(p_id),
		Owner:      p_owner,
		Plan_name:  plan_name,
		Activities: activities,
		From_date:  from_date,
		To_date:    to_date,
		Live_place: live_place,
		Budget:     fmt.Sprint(budget),
		Expenses:   expenses,
	}, nil
}

func SearchAllPlans(owner string) ([]Travel, error) {
	rows, err := db.Query("SELECT * FROM plans WHERE owner = '" + owner + "'")

	if err != nil {
		return []Travel{}, err
	}

	var p_id int
	var p_owner string
	var plan_name string
	var activities string
	var from_date string
	var to_date string
	var live_place string
	var budget int
	var expenses string

	vals := []Travel{}

	for rows.Next() {
		rows.Scan(&p_id, &p_owner, &plan_name, &activities, &from_date, &to_date, &live_place, &budget, &expenses)
		vals = append(vals,
			Travel{
				Id:         fmt.Sprint(p_id),
				Owner:      p_owner,
				Plan_name:  plan_name,
				Activities: activities,
				From_date:  from_date,
				To_date:    to_date,
				Live_place: live_place,
				Budget:     fmt.Sprint(budget),
				Expenses:   expenses,
			},
		)
	}

	return vals, nil
}

func InsertPlan(plan Travel) bool {
	_, err := db.Exec(
		fmt.Sprintf(
			"INSERT INTO plans (owner, plan_name, activities, from_date, to_date, live_place, budget, expenses) VALUES ('%s', '%s', '%s', '%s' '%s', '%s', %s, '%s')",
			getFieldString(&plan, "Owner"),
			getFieldString(&plan, "Plan_name"),
			getFieldString(&plan, "Activities"),
			getFieldString(&plan, "From_date"),
			getFieldString(&plan, "To_date"),
			getFieldString(&plan, "Live_place"),
			getFieldString(&plan, "Budget"),
			getFieldString(&plan, "Expenses"),
		),
	)

	return err == nil
}
