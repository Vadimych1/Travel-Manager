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
	Id        int
	Email     string
	Password  string
	Name      string
	Subscribe string
}

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

func getFieldString(e *Travel, field string) string {
	r := reflect.ValueOf(e)
	f := reflect.Indirect(r).FieldByName(field)
	return f.String()
}

func Init(logger *log.Logger) {
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

	logger.Println("Connected to database")
	log.Println("Connected to database")
}

func InsertUser(usrname string, pwd string, name string) bool {
	fmt.Println("Inserting user...")
	_, err := db.Exec("INSERT INTO users (email,password,name) VALUES ('" + usrname + "','" + pwd + "','" + name + "')")

	if err != nil {
		fmt.Println(err)
		return false
	}

	// fmt.Print(res)
	return true
}

func SearchUser(usrname string) []User {
	fmt.Println("Seqrching user...")
	rows, err := db.Query("SELECT * FROM users WHERE email = '" + usrname + "'")

	if err != nil {
		fmt.Print(err)
	}

	var id int
	var email string
	var password string
	var name string
	var subscribe string

	results := []User{}

	for rows.Next() {
		rows.Scan(&id, &email, &password, &name, &subscribe)
		results = append(results, User{Id: id, Email: email, Password: password, Name: name, Subscribe: subscribe})
	}

	return results
}

func SearchTravel(id int, usrname string) (Travel, error) {
	fmt.Println("Searching travel...")

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
	var meta string
	var town string
	var people_count string

	if rows.Next() {
		rows.Scan(&p_id, &p_owner, &plan_name, &activities, &from_date, &to_date, &live_place, &budget, &expenses, &meta, &town, &people_count)
	} else {
		return Travel{}, errors.New("SearchError: plan not found")
	}

	return Travel{
		Id:          fmt.Sprint(p_id),
		Owner:       p_owner,
		Plan_name:   plan_name,
		Activities:  activities,
		From_date:   from_date,
		To_date:     to_date,
		Live_place:  live_place,
		Budget:      fmt.Sprint(budget),
		Expenses:    expenses,
		Meta:        meta,
		Town:        town,
		PeopleCount: people_count,
	}, nil
}

func SearchAllPlans(owner string) ([]Travel, error) {
	fmt.Println("Seqrching all plans")

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
	var meta string
	var town string
	var people_count string

	vals := []Travel{}

	for rows.Next() {
		rows.Scan(&p_id, &p_owner, &plan_name, &activities, &from_date, &to_date, &live_place, &budget, &expenses, &meta, &town, &people_count)
		vals = append(vals,
			Travel{
				Id:          fmt.Sprint(p_id),
				Owner:       p_owner,
				Plan_name:   plan_name,
				Activities:  activities,
				From_date:   from_date,
				To_date:     to_date,
				Live_place:  live_place,
				Budget:      fmt.Sprint(budget),
				Expenses:    expenses,
				Meta:        meta,
				Town:        town,
				PeopleCount: people_count,
			},
		)
	}

	return vals, nil
}

func InsertPlan(plan Travel) bool {
	fmt.Println("Inserting plan...")

	_, err := db.Exec(
		fmt.Sprintf(
			"INSERT INTO plans (`owner`, plan_name, activities, from_date, to_date, live_place, budget, expenses, meta, town, people_count) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', %s, '%s', '%s', '%s', '%s')",
			getFieldString(&plan, "Owner"),
			getFieldString(&plan, "Plan_name"),
			getFieldString(&plan, "Activities"),
			getFieldString(&plan, "From_date"),
			getFieldString(&plan, "To_date"),
			getFieldString(&plan, "Live_place"),
			getFieldString(&plan, "Budget"),
			getFieldString(&plan, "Expenses"),
			getFieldString(&plan, "Meta"),
			getFieldString(&plan, "Town"),
			getFieldString(&plan, "PeopleCount"),
		),
	)

	fmt.Println(err)
	return err == nil
}
