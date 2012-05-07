package main

import "./template_opaque"

func main() {
	v := template_opaque.NewOpaqueVectorType(10)

	template_opaque.FillVector(v)
}
