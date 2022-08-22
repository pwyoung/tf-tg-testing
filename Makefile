.PHONY=default apply plan format FORCE

D:=./multi-cloud/non-prod/multi-region/dev/omnibus

# Just go into the directory specified in $D and run the given target

default: apply

apply: FORCE
	cd $(D) && make $1

clean: FORCE
	cd $(D) && make $1

FORCE:
