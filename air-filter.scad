// (c) 2021 Henner Zeller. License: CC-BY-SA
$fn=90;
e=0.05;

ply_thick=6;      // mm. Measured plywood thickness.
ply_wiggle=0.1;   // Space around slots finger slots.

filter_wiggle_room=1;

// Filter sizes according to https://amazon.com/dp/B00CJZ7TB2
// (but then measured)
filter_w = (filter_wiggle_room + 393);   // mm Wide
filter_h = (filter_wiggle_room + 622);   // mm High
filter_t = (filter_wiggle_room + 94);    // mm Thick

filter_rim=25;             // cardboard edge around filter

fan_inner_r=10*25.4;       // Visualization of fan size.
fan_hold_ring_inner=117;
fan_hold_ring_outer=fan_hold_ring_inner + 2*15;
fan_foam_thick=30;

fan_ring_pos=filter_h - ply_thick - fan_foam_thick;

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

module fan_ring_base() {
     difference() {
	  cylinder(r=fan_hold_ring_outer/2, h=ply_thick);
	  translate([0, 0, -e]) cylinder(r=fan_hold_ring_inner/2, h=ply_thick+2*e);
     }
}

module fan_ring() {
     difference() {
	  fan_ring_base();
	  translate([0, 0, -fan_ring_pos]) {
	       rotate([0, 0, -45]) fan_holder();
	       rotate([0, 0, +45]) fan_holder();
	  }
     }
}

module fan_holder(extra=0, left=false) {
     center_clearance=0.8;  // Leave a bit of center wiggle room
     finger_w=12;
     t = ply_thick + extra;
     diagonal = (filter_w-7) * sqrt(2);
     center_w=fan_hold_ring_outer;
     difference() {
	  union() {
	       // Main body
	       hull() {
		    translate([-t/2, -center_w/2, 0]) cube([t, center_w, fan_ring_pos]);
		    translate([-t/2, -200/2, 0]) cube([t, 200, 10]);
	       }


	       // one side-arm
	       for (symmetry = [-1, 1]) hull() {
		    translate([-t/2, symmetry*(diagonal/2-finger_w/2), filter_h-e-finger_w/2])
			 rotate([0, 90, 0]) cylinder(r=finger_w/2, h=t);

		    translate([-t/2, symmetry*fan_hold_ring_inner/2, fan_ring_pos-60])
			 rotate([0, 90, 0]) cylinder(r=30, h=t);
	       }

	  }

	  // Space to house motor
	  translate([0, 0, fan_ring_pos - 40])
	       cylinder(r=fan_hold_ring_inner/2, h=45);

	  // Vertical slot
	  translate([-25, -t/2, left ? 0 : filter_h/2-center_clearance])
	       cube([50, t, filter_h/2+center_clearance]);
     }

     // vertical slot needed

     for (symmetry = [-1, 1]) {
	  scale([1, symmetry, 1]) {
	       // Bottom fingers
	       for (notch = [40, 90]) {
		    translate([-t/2, notch-finger_w/2, -ply_thick-e]) cube([t, finger_w, ply_thick+2*e]);
	       }

	       // Top fingers
	       translate([-t/2, diagonal/2-finger_w, filter_h-e-finger_w/2]) cube([t, finger_w, ply_thick+2*e+finger_w/2]);

	       // Fingers for motor fan_ring
	       translate([-t/2, fan_hold_ring_inner/2-2*e, fan_ring_pos]) cube([t, 8, ply_thick+2*e]);
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
	  rotate([0, 0, +45]) fan_holder(extra=ply_wiggle);
	  rotate([0, 0, -45]) fan_holder(extra=ply_wiggle);
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

     translate([0, 0, 1.1*filter_h * explode_factor])
	  rotate([0, 0, -45]) fan_holder(left=true);
     rotate([0, 0, +45]) fan_holder();
     translate([0, 0, 1.15*filter_h * explode_factor])
	  translate([0, 0, fan_ring_pos]) fan_ring();
}

module top_2d() { projection(cut=false) top_board(); }
module bottom_2d() { projection(cut=false) bottom_board(); }
module zarge_2d() {
     projection(cut=false) rotate([90, 0, 0]) zarge(extra=0);
}

module fan_ring_2d() {
     projection(cut=false) fan_ring();
}

module fan_holder_2d(left=true) {
     projection(cut=false) rotate([0, 90, 0]) fan_holder(extra=ply_wiggle, left=left);
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

     translate([900, -600, 0]) {
	  translate([0, filter_h+20, 0]) fan_ring_2d();
	  translate([180, filter_h-125, 0]) rotate([0, 0, -90]) fan_holder_2d(left=false);
	  rotate([0, 0, 90]) fan_holder_2d(left=true);
     }
}


//cuts();
rotate([0, 0, 180*$t]) assembly(show_filter=false);
