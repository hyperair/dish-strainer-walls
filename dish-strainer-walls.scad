include <MCAD/units/metric.scad>
use <MCAD/array/rectangular.scad>
use <MCAD/array/mirror.scad>
use <MCAD/fillets/primitives.scad>

corner_r = 35;
corner_width = 72;
corner_depth = 70;

centre_width = 51;
centre_corner_r = 8;

hole_height = 104.65;
hole_stub_height = 10;

base_r = 4;

wall_thickness = 1;

$fs = 0.4;
$fa = 1;

module basic_corner_shape()
{
    difference() {
        offset(r=centre_corner_r)
        offset(r=-centre_corner_r)
        square([corner_width, corner_depth]);

        /* large rounding radius */
        translate([corner_width, 0])
        mirror(X)
        translate([-1, -1] * epsilon)
        mcad_fillet_primitive(angle=90, radius=corner_r);
    }
}

module shell()
{
    difference() {
        children();

        offset(r=-wall_thickness)
        children();
    }
}

module make_base_shape()
{
    difference() {
        offset(r=base_r)
        children();

        offset(r=-wall_thickness)
        children();
    }
}

module corner_strainer_wall()
{
    render()
    difference() {
        union() {
            /* walls */
            linear_extrude(hole_height)
            shell()
            basic_corner_shape();

            /* base */
            translate([0, 0, hole_height - epsilon])
            linear_extrude(wall_thickness)
            make_base_shape()
            basic_corner_shape();
        }

        /* remove back wall */
        cube([corner_width, 10, hole_height - hole_stub_height]);

        /* remove side wall */
        translate([corner_width - wall_thickness - 29, -1])
        cube([30, corner_depth, hole_height - hole_stub_height]);
    }
}

module basic_centre_shape()
{
    w = centre_width;
    h = corner_depth;

    offset(centre_corner_r)
    offset(-centre_corner_r)
    square([w, h]);
}

module centre_strainer_wall()
{
    render()
    difference() {
        union() {
            linear_extrude(hole_height)
            shell()
            basic_centre_shape();

            translate([0, 0, hole_height - epsilon])
            linear_extrude(wall_thickness)
            make_base_shape()
            basic_centre_shape();
        }

        /* remove back wall */
        translate([-epsilon, 0])
        cube([corner_width, 10, hole_height - hole_stub_height]);
    }
}

union() {
    mcad_mirror_duplicate(X)
    translate([130/2, 0, 0])
    corner_strainer_wall();

    mcad_mirror_duplicate(X)
    translate([9.7/2, 0, 0])
    centre_strainer_wall();
}
