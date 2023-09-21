package main

type Aggregate struct {
	AggregateUUID string
	State         string
}

func (a *Aggregate) Apply(e Event) {
	a.State += e.Data
}