// db.go
package main

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"time"
)

func SetupDatabase() *gorm.DB {
	dsn := "host=db user=dbuser password=dbpass dbname=apples port=5432 sslmode=disable TimeZone=Etc/UTC"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	sqlDB, err := db.DB()
	if err != nil {
		panic("failed to access database connection")
	}
	
	sqlDB.SetMaxIdleConns(30)
	sqlDB.SetMaxOpenConns(1000)
	sqlDB.SetConnMaxLifetime(time.Hour)
	// Migrate the schema
	db.AutoMigrate(&Event{})

	return db
}