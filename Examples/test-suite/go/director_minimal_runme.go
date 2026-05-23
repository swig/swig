package main

import dm "swigtests/director_minimal"

type MyMinimal struct{}

func (p *MyMinimal) Run() bool {
  return true
}

func main() {
    c := dm.NewDirectorMinimal(&MyMinimal{})
    if !c.Get() {
      panic("Should return true")
    }
}
