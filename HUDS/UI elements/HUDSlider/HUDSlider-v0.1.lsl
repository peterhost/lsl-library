//*********************************************************************
//                                                                    *
///                       --HUD Slider--                              *
//                                                                    *
//*********************************************************************
// HUD Slider - v 0.1
//
// by:		Peter Host (Pete Atolia inworld)
// License:	BSD, but please provide patches/bugfixes if you can!
//
// Description: provides a slider in one prim to be linked to a HUD.
//              slider speaks it's position on chat channel
//
// Usage: 1) add the texture in the same directory to a prim cube
//        2) place this script in the prim
//        3) let the script initialize 
//        4) do whatever you want with the slider
//
//        this script just says the slider position as a 0-100 number
//        (adjust variable HUDchannel)


//____________________________________________________________________
//                          GLOBAL variables
//....................................................................
//                         USER
//....................................................................

// slider UI params
vector primPos = <0.5,0,0>; // only the x comonent (slider initial
                            // position) matters

float primscale = .5;       // the prim's size (positive number)
                            // 1 = medium, 0.5 = small, 2 = big
                            
integer resetOnRez = TRUE;  // disable if you don't want the prim to be 
                            // resized to 'primScale' on prim Rez
                            // as texture positioning on a slider is tricky
                            // you might need it to restore the defaults
                            
integer textOn = TRUE;      // false to disable percentage display


// slider color/texture
string sliderTexture;       // put a name here if you wish the HUD to
                            // use a specific texture instead of the
                            // first one it finds

                            // three zones defining slider's color
integer slowLimit = 20;     //%  blue (0-100)
integer safeLimit = 60;     //%  green (0-100)
                            // over that : red

integer primCOn = TRUE;     // false to disable slider color change

// communication
integer HUDchannel = 999;
integer sayPercent = TRUE;  // true : the script reports the 'percent' on channel HUDchannel


                                 
//....................................................................
//                         COMPUTED
//....................................................................

vector UV;
integer percent = 50;       // the slider's (output) value
vector textColor;
vector primColor;


//____________________________________________________________________
//                          Initialization
//....................................................................

init() {
    reloadTexture();
    
    llSetTexture(TEXTURE_TRANSPARENT,0);
    llSetTexture(TEXTURE_TRANSPARENT,1);
    llSetTexture(TEXTURE_TRANSPARENT,3);

    
    // a virer
    llSetColor(<1,1,1>, ALL_SIDES);
    
    // TEXTURES
    //note: face indexes for HUD attachement of this object
    
    llSetTexture(sliderTexture, 2);
    llSetTexture(sliderTexture, 4);
    llSetTexture(sliderTexture, 5);

    //front face (5)

    llOffsetTexture(0,0,5);
    llScaleTexture(1,0.333333,5);
    llSetText("", <1,0,0>, 0.5);
    
    llOffsetTexture(0.5 - primPos.x, 0.666, 5); // hover effect
    llOffsetTexture(0.5 - primPos.x, 0, 5);     // do this so that it's "loaded"
    
    //right face (2)
    
    llScaleTexture(0.02,0.333333,2);
    llRotateTexture(-PI_BY_TWO, 2);
    llOffsetTexture(-0.02,0.356,2);    

    //left face (4)
    
    llScaleTexture(0.02,0.333333,4);
    llRotateTexture(-PI_BY_TWO, 4);
    llOffsetTexture(0.98,0.333,4);



}

init_hard() {
    if (resetOnRez) restorePrimShape();
    init();
    
}

// in case we need that
restorePrimShape() {
        llSetPrimitiveParams( [PRIM_ROTATION, llEuler2Rot(<0, PI_BY_TWO, PI + PI_BY_TWO>)] );
        list params = [  9,
                         0,
                         0,
                        <0.000000, 1.000000, 0.000000>,
                         0.000000,
                        <0.000000, 0.000000, 0.000000>,
                        <1.030000, 1.000000, 0.000000>,
                        <0.000000, 0.000000, 0.000000>
                    ];
        llSetPrimitiveParams( params);
        llSetPrimitiveParams( [PRIM_SIZE, primscale * <0.25, 0.02, 0.01>] );
        llOwnerSay("prim shape restored");
   
}

reloadTexture() {
    if (sliderTexture == "") sliderTexture = llGetInventoryName(INVENTORY_TEXTURE, 0);
    
}


//____________________________________________________________________
//                          UI
//....................................................................

updateColorGlobs(integer init) { //don't update prim color if init == TRUE
    if (percent < slowLimit) {
        textColor = <0.5,0.5,1>;
        primColor =  <0.8,0.8,1>;
        
    }
    else if (percent > safeLimit) {
        textColor = <1,0.2,0.2>;
        primColor =  <1,0.8,0.8>;
    }
    else {
        textColor = <0.5,1,0.5>;
        primColor =  <0.8,1,0.8>;
    }
    
    if (textOn) llSetText((string)(percent) + "%", textColor,1);
    if (primCOn && !init) llSetColor(primColor, ALL_SIDES);    

}

sayResult() {
    if (sayPercent) llSay(HUDchannel, (string)percent);   
}
//____________________________________________________________________
//                          STATES
//....................................................................

default
{
    state_entry()
    {
        init(); 
        updateColorGlobs(TRUE);
        //llOwnerSay("init completed");      
    }
    
    on_rez(integer start_param)
    {
        init_hard();
    }

    touch_start(integer total_number)
    {
        llOffsetTexture(0.5 - primPos.x, 0.666, 5);
        updateColorGlobs(FALSE);
        //llSay(0, "Touched.");
        
    }
    
    touch(integer total_number)
    {
            
        // only detect touches on the front face (5)
        if (llDetectedTouchFace(0) == 5) {
            
            primPos = llDetectedTouchST(0);
            
            // carefull on the borders
            if (primPos.x >= 0.02 && primPos.x <= 0.98 ) llOffsetTexture(0.5 - primPos.x , 0.666, 5);
            else if (primPos.x < 0.02) primPos.x = 0.02;
            else primPos.x = 0.98;
            
            percent = llFloor( 100 * (primPos.x - 0.02 ) / 0.96 );
            updateColorGlobs(FALSE);
            sayResult();          

        }
        //else llOwnerSay("out of coords!!");
          
    }
    
    touch_end(integer total_number)
    {
        //llSay(0, "end touch"); 
        llOffsetTexture(0.5 - primPos.x, 0, 5);
        if (primCOn) llSetColor(<1,1,1>, ALL_SIDES);
    }



}