package main

import (
	"flag"
	"fmt"
	"net"
	"os"
	"time"
)

func main() {
	var timeout int
	var host, port string
	
	flag.IntVar(&timeout, "timeout", 30, "Timeout in seconds")
	flag.StringVar(&host, "host", "", "Host to wait for")
	flag.StringVar(&port, "port", "", "Port to wait for")
	
	flag.Parse()
	
	if host == "" || port == "" {
		fmt.Println("Usage: wait-for -host <host> -port <port> [-timeout <seconds>]")
		os.Exit(1)
	}
	
	fmt.Printf("Waiting for %s:%s (timeout: %d seconds)\n", host, port, timeout)
	
	address := fmt.Sprintf("%s:%s", host, port)
	
	timeoutDuration := time.Duration(timeout) * time.Second
	start := time.Now()
	
	for {
		conn, err := net.DialTimeout("tcp", address, 5*time.Second)
		if err == nil {
			conn.Close()
			fmt.Printf("Service at %s:%s is available after %v\n", host, port, time.Since(start))
			os.Exit(0)
		}
		
		if time.Since(start) > timeoutDuration {
			fmt.Printf("Timeout after %d seconds waiting for %s:%s\n", timeout, host, port)
			os.Exit(1)
		}
		
		time.Sleep(1 * time.Second)
	}
}