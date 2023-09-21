// models.go
package main

import (
	"time"
)

type Event struct {
	ID           uint `gorm:"primaryKey"`
	AggregateUUID string `gorm:"index"`
	Data         string
	CreatedAt    time.Time
}

type Command struct {
	Data string `json:"data"`
}
