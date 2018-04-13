run:
	make graphql web -j 2

graphql:
	make --directory=golang

web:
	make --directory=js
