package main

import (
	"crypto/aes"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	userdb "travel_server/src/db"
	handler "travel_server/src/handler"
	resp "travel_server/src/responses"
)

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
var log_file, _ = os.OpenFile(fmt.Sprintf("logs/log-%d-%d-%d.log", time.Now().Year(), time.Now().Month(), time.Now().Day()), os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
var logger = log.New(io.Writer(log_file), "", 0)

// Print log
func Log(toLog string) {
	logger.Println(toLog)
	log.Default().Println(toLog)
}

var encode_key string

// Run main function
func run_server() {
	logger.Println("-----------------" + time.Now().Format(time.DateOnly) + "--------------")
	settings := ReadSettings()

	Log("Starting HTTP server on " + string(settings["port"]))
	encode_key = string(settings["encode_key"])

	userdb.Init(logger)

	handler.SetEncodeKey(encode_key)
	handler.SetLogger(logger)

	go func() {
		for {
			Log("Clearing old travels")
			handler.ClearTravels()
			time.Sleep(time.Hour * 12)
		}
	}()

	// todo
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
			handler.Get(s, params, w, r, settings)
		} else if r.Method == "POST" {
			handler.Post(s, w, r)
		} else {
			resp.UnknownMethod(w, "GET or POST")
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
		go run_server()
		for {
			var command string
			fmt.Scanln(&command)
			switch command {
			case "exit", "quit", "stop", "q":
				os.Exit(0)
			case "help", "h":
				print_help()
			case "methods", "m":
				print_methods()
			default:
				fmt.Println("	Unknown command: " + command)
				print_help()
			}
		}
	}
}
