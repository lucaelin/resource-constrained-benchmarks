// main.go
package main

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
)

var db *gorm.DB


func handleCommand(c *gin.Context) {
	var cmd Command
	if err := c.BindJSON(&cmd); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	aggregateUUID := c.Param("uuid")

	// Query all existing events
	var events []Event
	db.Where("aggregate_uuid = ?", aggregateUUID).Find(&events)

	// Apply all existing events to the aggregate
	aggregate := Aggregate{AggregateUUID: aggregateUUID}
	for _, event := range events {
		aggregate.Apply(event)
	}

	// Create a new event from the command
	event := Event{AggregateUUID: aggregateUUID, Data: cmd.Data}

	// Apply the new event to the aggregate
	aggregate.Apply(event)

	// Store and return the new event
	db.Create(&event)
	c.JSON(http.StatusOK, event)
}

func handleQuery(c *gin.Context) {
	aggregateUUID := c.Param("uuid")

	// Query all existing events
	var events []Event
	db.Where("aggregate_uuid = ?", aggregateUUID).Find(&events)

	// Apply all events to the projection
	projection := Projection{}
	for _, event := range events {
		projection.Apply(event)
	}

	// Return the projection's state
	c.JSON(http.StatusOK, projection.State)
}

func main() {
	// Setup the database
	db = SetupDatabase()

	r := gin.Default()

	r.POST("/:uuid/command", handleCommand)
	r.GET("/:uuid/query", handleQuery)

	r.Run(":8080")
}