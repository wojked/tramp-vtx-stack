/* [BASE] */
BASE_WIDTH = 38.0;      // [16:0.5:40]
BASE_HEIGHT = 37.0;     // [16:0.5:40]
BASE_THICKNESS = 1;     // [0.1:0.1:4]
VENTS = true;           // [true, false]

/* [MOUNTING] */
HOLE_DIAMETER = 3.6;    // [2, 2.5, 3, 3.5] //3.1 is to small, 3.3 not yet ok
HOLE_X_OFFSET = 30.5;   // [16, 20, 30.5]
HOLE_Y_OFFSET = 30.5;   // [16, 20, 30.5]

MOUNT_WIDTH = 6;
MOUNT_HEIGHT = 4;
MOUNT_HOLE_WIDTH = 3.5;
MOUNT_HOLE_THICKNESS = 1.6; //0.7
MOUNT_Z_OFFSET = 1;

/* [SUPPORTS] */
SUPPORT_WIDTH = 17.4;
SUPPORT_HEIGHT = 17.4;
SUPPORT_THICKNESS = 2.5;    // [3:0.1:5]
SUPPORT_X_OFFSET = -3;     // previously 2.0
LIMITER_THICKNESS = SUPPORT_THICKNESS + 1.5;
LIMITER_DIAMETER = 4;

/* [META] */
CORNERS_DIAMETER = 2;   // [16:0.5:40]
FN = 64;               // [0:32:256]  

/* [HIDDEN] */
$fn = FN;


vtx_support();


module vtx_support(){    
    union(){
        translate([0,0, BASE_THICKNESS/2])        
        base_with_holes();
        
        translate([SUPPORT_X_OFFSET,0, BASE_THICKNESS + SUPPORT_THICKNESS/2])        
        supports(SUPPORT_WIDTH, SUPPORT_HEIGHT, SUPPORT_THICKNESS);
    }
}


module base_with_holes(base_thickness){
    difference(){        
        base();

        if(VENTS){
            middle_vents();                
        }
        
        holes_group();        
    }
}

module base(){
    y_offset = BASE_HEIGHT/2 + 9;
    
    difference(){
        rounded_corners(BASE_WIDTH, BASE_HEIGHT, BASE_THICKNESS, CORNERS_DIAMETER);
        
        translate([0, y_offset, 0])
        cutout();
        
        translate([0, -y_offset, 0])
        cutout();        
    }
}

module cutout(){
    size = 15;
    rounded_corners(BASE_WIDTH-size, BASE_HEIGHT, BASE_THICKNESS*2, CORNERS_DIAMETER);    
}

module middle_vents(){
    x_offset = 4;
    width = 2;
    height = 8;

    for(i = [-4 : 1 : 1]){
        
        translate([x_offset*i, 0, 0])
        cube([width, height, BASE_THICKNESS*2], true);      
    }
}

module holes_group(){
    x_offset = HOLE_X_OFFSET/2;
    y_offset = HOLE_Y_OFFSET/2;
    
    translate([x_offset,y_offset,0])
    cylinder_hole();
    
    translate([x_offset,-y_offset,0])
    cylinder_hole();

    translate([-x_offset,-y_offset,0])
    cylinder_hole();

    translate([-x_offset,y_offset,0])
    cylinder_hole();
}

module cylinder_hole(){
    thickness = (BASE_THICKNESS+SUPPORT_THICKNESS)*2;
    diameter = HOLE_DIAMETER;    
    cylinder(thickness, diameter/2, diameter/2, true);            
}

module supports(width, height, thickness){
    support_diameter = LIMITER_DIAMETER;
    front_support_extra_offset = 1.5;
    back_support_offset = 2.5;
    x_offset = width/2-support_diameter/2;
    y_offset = height/2-support_diameter/2;        
    
    translate([x_offset,y_offset,0])
    single_support(support_diameter, thickness);
    
    translate([x_offset,-y_offset,0])
    single_support(support_diameter, thickness);

    translate([-x_offset,-y_offset-front_support_extra_offset,0])
    single_support(support_diameter, thickness);

    translate([-x_offset,y_offset+front_support_extra_offset,0])
    single_support(support_diameter, thickness);
    
    translate([3,y_offset,0])    
    secure_mount(thickness);
    
    translate([3,-y_offset,0])    
    secure_mount(thickness);    
    
    // back support
    translate([x_offset + 4,-back_support_offset,0])
    single_support(support_diameter, thickness);     
    
    limiter_z_offset = (LIMITER_THICKNESS - thickness)/2;
    
    // back limiter
    translate([x_offset + 5.8,-back_support_offset, limiter_z_offset])        
    limiter(support_diameter, LIMITER_THICKNESS);    
    
    // side limiters
    side_limiter_extra_offset = 4.2;
    translate([-x_offset,y_offset + side_limiter_extra_offset, limiter_z_offset])    
    limiter(support_diameter, LIMITER_THICKNESS); 
    
    translate([-x_offset,-y_offset - side_limiter_extra_offset, limiter_z_offset])        
    limiter(support_diameter, LIMITER_THICKNESS);     
}

module single_support(support_diameter, thickness){
    rounded_corners(support_diameter, support_diameter, thickness, CORNERS_DIAMETER);      
}

module limiter(limter_diameter, thickness){
    cube([limter_diameter,limter_diameter, thickness], true);
    
    //base
    translate([0,0,-(thickness+BASE_THICKNESS)/2])
    cube([limter_diameter,limter_diameter, BASE_THICKNESS], true);
}

module rounded_corners(width, height, depth, corner_curve){
    x_translate = width-corner_curve;
    y_translate = height-corner_curve;     
    
    hull(){
            translate([-x_translate/2, -y_translate/2, 0])
            cylinder(depth,corner_curve/2, corner_curve/2, true);    
            
            translate([-x_translate/2, y_translate/2, 0])
            cylinder(depth,corner_curve/2, corner_curve/2, true);

            translate([x_translate/2, y_translate/2, 0])
            cylinder(depth,corner_curve/2, corner_curve/2, true);        
            
            translate([x_translate/2, -y_translate/2, 0])
            cylinder(depth,corner_curve/2, corner_curve/2, true);        
    }        
}


module secure_mount(thickness){
    diff = (thickness-MOUNT_HOLE_THICKNESS)/2 - MOUNT_Z_OFFSET;
    difference(){
        cube([MOUNT_WIDTH, MOUNT_HEIGHT, thickness], true);          
        
        translate([0,0, diff])
        cube([MOUNT_HOLE_WIDTH, MOUNT_HEIGHT*2, MOUNT_HOLE_THICKNESS], true);        
    }
}
