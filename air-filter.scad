// (c) 2021 Henner Zeller. License: CC-BY-SA
$fn=50;
e=0.05;

ply_thick=6;      // mm. Measured plywood thickness.
ply_wiggle=0.1;   // Space around slots finger slots.

filter_wiggle_room=1;

// Filter sizes according to https://amazon.com/dp/B00CJZ7TB2
filter_w = (filter_wiggle_room + 391);   // mm Wide
filter_h = (filter_wiggle_room + 619.5); // mm High
filter_t = (filter_wiggle_room + 92.5);  // mm Thick

filter_rim=30;             // cardboard edge around filter

fan_inner_r=10*25.4;       // Visualization of fan size.

// Animation of the 'explosion' view.
explode_factor=-cos(360*$t)/2+0.5;

module filter_material(h=filter_h-filter_wiggle_room-2*filter_rim,
		       thick=filter_t, d=10,
		       w=filter_w-filter_wiggle_room-2*filter_rim) {
     r=3;
     color("lightgray") {
	  for (yoff = [-w/2 : 2*d : w/2]) translate([0, yoff, 0]) {
	       hull() {
		    cylinder(r=r, h=h);
		    translate([thick, d, 0]) cylinder(r=r, h=h);
	       }
	       hull() {
		    translate([thick, d, 0]) cylinder(r=r, h=h);
		    translate([0, 2*d, 0]) cylinder(r=r, h=h);
	       }
	  }
     }
}

module zarge(left=false, ply_thick = ply_thick, extra=0) {
     center_clearance=0.8;  // Leave a bit of center wiggle room
     outer_move = filter_rim + ply_thick;
     color("brown") translate([-outer_move, 0, 0]) {
	  difference() {
	       cube([filter_t + outer_move, ply_thick, filter_h]);
	       translate([filter_rim-ply_wiggle/2, -25,
			  left ? 0 : filter_h/2-center_clearance])
		    cube([ply_thick+ply_wiggle, 50, filter_h/2+center_clearance]);
	  }

	  // Fingers mounting to top/bottom.
	  finger_w=15;
	  for (notch = [0.2, 0.7]) {
	       translate([notch * (filter_t-finger_w) + outer_move - extra, -extra/2, -ply_thick-0.5]) cube([finger_w+2*extra, ply_thick+extra, filter_h+2*ply_thick+1]);
	  }
     }
}

module bottom_stop(extra=0) {
     w = filter_w - 2*filter_rim - 2;
     color("blue") translate([-ply_thick, -w/2, 0]) {
	  cube([ply_thick, w, filter_rim]);
	  finger_w=15;
	  for (notch = [1/6, 3/6, 5/6]) {
	       translate([-extra/2, notch * (w-finger_w) - extra, -ply_thick-0.5]) cube([ply_thick+extra, finger_w+2*extra, filter_rim+ply_thick+0.5]);
	  }
     }
}

module filter_zargen(extra=0, explode=0) {
     z_explode=1.1 * filter_h * explode;
     translate([0, -filter_w/2-ply_thick, z_explode]) zarge(left=true, extra=extra);
     translate([0, +filter_w/2, 0]) zarge(left=false, extra=extra);

     stop_explode = 0.2*filter_h*explode;
     translate([0, 0, stop_explode]) bottom_stop(extra=extra);
     translate([-ply_thick, 0, filter_h+1.2*filter_h*explode]) rotate([0, 180, 0]) bottom_stop(extra=extra);
}

module filter(show_filter=true, extra=0, explode=0) {
     // 15.38" x 24.38" x 3.63"
     if (show_filter) {
	  fw = filter_wiggle_room;
	  translate([0, 0, filter_rim+fw/2]) filter_material();
	  translate([0, -(filter_w-fw) / 2, fw/2])
	       if (true) color("darkgray") difference() {
			 cube([filter_t, filter_w-fw, filter_h-fw]);
			 translate([-e, filter_rim, filter_rim])
			      cube([filter_t+2*e, filter_w-fw-2*filter_rim, filter_h-fw-2*filter_rim]);
		    }
     }

     filter_zargen(extra=extra, explode=explode);
}

module filter_half_box(show_filter, extra=0, explode=0) {
     translate([filter_w/2 + ply_thick, 0, 0])
	  filter(show_filter, extra, explode);
     translate([0, filter_w/2+ply_thick, 0])
	  rotate([0, 0, 90]) filter(show_filter, extra, explode);
}

module filter_box(show_filter=true, extra=0, explode=0) {
     filter_half_box(show_filter, extra, explode);
     rotate([0, 0, 180]) filter_half_box(show_filter, extra, explode);
}

module fan_holder(extra=0) {
     t = ply_thick + extra;
     diagonal = (filter_w-7) * sqrt(2);
     rotate([0, 0, 45]) {
	  //translate([-t/2, -diagonal/2, 0]) cube([t, diagonal, filter_h]);
	  // nice shape needed.
	  // vertical slot needed
	  finger_w=12;
	  for (symmetry = [-1, 1]) {
	       scale([1, symmetry, 1]) {
		    for (notch = [40, 90]) {
			 translate([-t/2, notch-finger_w/2, -ply_thick-e]) cube([t, finger_w, ply_thick+2*e]);
		    }
		    translate([-t/2, diagonal/2-finger_w, filter_h-e]) cube([t, finger_w, ply_thick+2*e]);
	       }
	  }
     }
}

module fan() {
     if (false) difference() {  // inner shroud
	  cylinder(r=fan_inner_r, h=100);
	  translate([0, 0, -e]) cylinder(r=9.8 * 25.4, h=101);
     }
     if (true) difference() {  // outer shroud
	  cylinder(r=550/2, h=100);
	  translate([0, 0, -e]) cylinder(r=540/2, h=101);
     }
     d=60;
     translate([0, 0, 50]) color("silver") {
	  cylinder(r=d, h=30);
	  for (a = [0, 120, 240]) {
	       rotate([0, 0, a])
		    translate([0, -60/2, 0]) cube([19/2 * 25.4, 60, 0.1]);
	  }
     }
}

module rounded_box(w, h, r, thick=ply_thick) {
     hull() {
	  ww = w/2 - r;
	  hh = h/2 - r;
	  for (x = [-1, 1]) {
	       for (y = [-1, 1]) {
		    translate([x*ww, y*hh, 0]) cylinder(r=r, h=thick);
	       }
	  }
     }
}

module box_end() {
     d = filter_w + 2*(filter_t + ply_thick);
     color("beige") rounded_box(d, d, filter_t);
}

module bottom_board() {
     difference() {
	  translate([0, 0, -ply_thick]) box_end();
	  translate([0, 0, e]) filter_box(show_filter=false, extra=ply_wiggle);
	  fan_holder(extra=ply_wiggle);
	  rotate([0, 0, 90]) fan_holder(extra=ply_wiggle);
     }
}

module top_board() {
     difference() {
	  translate([0, 0, filter_h]) difference() {
	       box_end();
	       d = filter_w + 0.5;
	       translate([0, 0, -e]) rounded_box(d, d, 60, ply_thick+1);
	  }
	  filter_box(show_filter=false, extra=ply_wiggle);

	  fan_holder(extra=ply_wiggle);
	  rotate([0, 0, 90]) fan_holder(extra=ply_wiggle);
     }
}


module assembly(show_filter=true) {
     translate([0, 0, -0.3*filter_h * explode_factor]) bottom_board();
     translate([0, 0, 1.3*filter_h * explode_factor]) top_board();
     filter_box(show_filter=show_filter, explode=explode_factor);
     translate([0, 0, filter_h + 1.5*filter_h * explode_factor]) fan();

     if (false) {  // fan holder not ready yet.
	  fan_holder();
	  rotate([0, 0, 90]) fan_holder();
     }
}

module top_2d() { projection(cut=false) top_board(); }
module bottom_2d() { projection(cut=false) bottom_board(); }
module zarge_2d() {
     projection(cut=false) rotate([90, 0, 0]) zarge(extra=0);
}

module bottom_stop2d() {
     projection(cut=false) rotate([0, 90, 0]) bottom_stop();
}

module cuts() {
     translate([-300, 0, 0]) top_2d();
     translate([300, 0, 0]) bottom_2d();
     for (i = [0 : 7]) {
	  translate([400 - i*(filter_t+filter_rim+ply_thick+5), -320, 0]) zarge_2d();
     }

     // Place these inside the empty space of the top.
     translate ([-485, 0, 0]) {
	  for (i = [0 : 7]) {
	       translate([i * (ply_thick+filter_rim+5), 0, 0]) bottom_stop2d();
	  }
     }
}


//cuts();
rotate([0, 0, 180*$t]) assembly(show_filter=false);