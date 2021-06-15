
PLY_THICKNESS=6

all : air-filter-cuts-$(PLY_THICKNESS)mm.dxf

# Create an scad file on-the-fly that calls that particular function
fab/air-filter-%.scad : air-filter.scad
	mkdir -p fab/
	echo "use <../air-filter.scad>; $*();" > $@

air-filter-cuts-%mm.dxf : fab/air-filter-cuts.scad
	openscad -Dply_thick=$* -o $@ $<

clean:
	rm -f air-filter-cuts*mm.dxf
