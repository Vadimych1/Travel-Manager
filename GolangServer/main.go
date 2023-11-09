package main

import (
	"fmt"
	"golangserver/GolangServer/server"
)

func main() {
	fmt.Println("Starting server")
	// database.Init()
	// id, err := database.FindUser("Vadim", "username")
	// fmt.Println(id, err)

	server.Start()
}
