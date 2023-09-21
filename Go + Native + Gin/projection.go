package main

type Projection struct {
	State string
}

func (p *Projection) Apply(e Event) {
	p.State += e.Data
}
