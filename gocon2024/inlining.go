package main

import "fmt"

type Point struct{ x, y int }

func (p Point) String() string {
	return fmt.Sprintf("(%d, %d)", p.x, p.y)
}

func NewPoint(x, y int) Point {
	return Point{x, y}
}

func f(x int) int {
	return x * x
}

func g(x int) int {
	return f(x*x*x*x*x*x) + 1
}

func main() {
	p := NewPoint(1, 2)

	fmt.Println(p)
	fmt.Println(g(2))
}
