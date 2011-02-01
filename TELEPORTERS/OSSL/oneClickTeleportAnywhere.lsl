//*********************************************************************
//                                                                    *
//               --One Click Teleport Anywhere--                      *
//                                                                    *
//*********************************************************************
// Script Name - v x.x.x
//
// by:          Peter Host (Pete Atolia inworld)
// License:     BSD, but please provide patches/bugfixes if you can!
//
// Language:    OSSL (opensim only)
//
// Description: Teleport anywhere (even hypergrid) with a single touch
//
// Usage:       cf. below
//
// Note : the OSSL function 'osTeleportAgent' has to be activated
//        in your OpenSim.ini, cf. below.
//____________________________________________________________________
//
// http://opensimulator.org/wiki/OsTeleportAgent
//
// osTeleportAgent
//
// Teleports an agent to the specified location.   
//
//
// 1) The first variant is able to teleport to **any addressable region**, including hypergrid destinations :
// osTeleportAgent(key UUID, string destinationTarget, vector position, vector lookAt)
//
// 2) The second variant teleports to a region in the **local grid**;
// the region coordinates are specified as region cells (not as global coordinates based on meters).
// osTeleportAgent(key UUID, integer regionX, integer regionY, vector position, vector lookAt)
//
// 3) The third variant teleports within the **current region**.
// osTeleportAgent(key UUID, vector position, vector lookAt) 
//
// For osTeleportAgent() to work, the owner of the prim containing the script must be the same as the parcel
// that the avatar is currently on. If this isn't the case then the function fails silently.
//
// These functions have a threat level of High and must be allowed in OpenSim.ini for operation 
// (see OSSL Enabling Functions for examples). Also see osTeleportOwner. 
//____________________________________________________________________
//                           USAGE
//____________________________________________________________________
//
// 1) choose a prim or linkset to be your teleporter
// 2) create a notecard following one of these 3 schemes :
//    (commented and empty lines in notecard are ignored)
//      // type 0 (any address)
//      0
//      // string TPdescription
//      MY super-duper hypergrided standalone
//      // string destinationTarget
//      hg.osgrid.org:80:Lbsa Plaza
//      // vector position
//       <129,136,30>
//      // vector lookAt
//      <128,128,128>
//
//      // type 1 (local grid)
//      // string TPdescription
//      // integer regionX
//      // integer regionY
//      // vector position
//      // vector lookAt
//      
//      // type 2 (current region)
//      // string TPdescription
//      // vector position
//      // vector lookAt
// 3) drop the notecard in the prim
// 4) drop this script in the prim
// 5) touch it :)
//____________________________________________________________________



//____________________________________________________________________
//                         GLOBAL variables
//....................................................................
//                         USER
//....................................................................

integer debug = TRUE;      
                         
//....................................................................
//                         COMPUTED
//....................................................................

list contents; // contents of the loaded notecard


string gName;   // name of the first notecard in the prim's inventory
key gUUID;      // UUID of that notecard (stored to detect notecard changes)
key gQueryID;   // ID of 
integer gLine;  // current line being read


                            //  type:   1   2   3
integer teleportType;       //          x   x   x   type of osTeleportAgent call (1, 2 or 3)
string  TPdescription;      //          x   x   x
string  destinationTarget;  //          x
integer regionX;            //              x
integer regionY;            //              x
vector position;            //          x   x   x
vector lookAt;               //          x   x   x


key avatarKey;  // as name suggests

//____________________________________________________________________
//                         Initialization
//....................................................................

init() {
    gName = llGetInventoryName(INVENTORY_NOTECARD, 0); // select the first notecard in the object's inventory
    gUUID = llGetInventoryKey(gName);   // save it's current UUID to detect changes
    gLine = -1;
    contents = [];
}

//____________________________________________________________________
//                           Title
//....................................................................

loadSettings() {
    //integer l = llGetListLength(contents);
    //integer i;
    teleportType = (integer)( (string)llList2List(contents,0,0) ); // type of osTeleportAgent call (amongst the 3)
 
    if ( teleportType == 1) { // HYPERGRID & all
        TPdescription =     (string)llList2List(contents,1,1);      
        destinationTarget = (string)llList2List(contents,2,2);  
        position =  (vector)( (string)llList2List(contents,3,3) );            
        lookAt =    (vector)( (string)llList2List(contents,4,4) );                     
    }
    else if (teleportType == 2) {
        TPdescription =     (string)llList2List(contents,1,1);      
        regionX =  (integer)( (string)llList2List(contents,2,2) ); 
        regionY =  (integer)( (string)llList2List(contents,3,3) ); 
        position =  (vector)( (string)llList2List(contents,4,4) );            
        lookAt =    (vector)( (string)llList2List(contents,5,5) );                  
    }
    else if (teleportType == 3) {
        TPdescription =     (string)llList2List(contents,1,1);      
        position =  (vector)( (string)llList2List(contents,2,2) );            
        lookAt =    (vector)( (string)llList2List(contents,3,3) );          
    }
    else {
        error("the notecard in this teleporter is not well configured.\n --> could not find teleportation type");
    }
    llSetText("Touch to teleport to \n" + TPdescription, <0,1,0>, 1);
}


//____________________________________________________________________
//                         MISC
//....................................................................

//....................................................................
// very basic regexp
//
// Examples
// like("Susie", "Sus%");  //will return true, for any value starting with "Sus"
// like("Susie", "%Sus%"); //will return true, for any value containing "Sus"
// like("Susie", "%Sus");  //will return false. This example is looking for a string ending in "Sus".
// like("Susie", "Sus");   //will return false. This example is looking for a string matching only "Sus" exactly.
integer like(string value, string mask) {
    integer tmpy = (llGetSubString(mask,  0,  0) == "%") | 
                  ((llGetSubString(mask, -1, -1) == "%") << 1);
    if(tmpy)
        mask = llDeleteSubString(mask, (tmpy / -2), -(tmpy == 2));
 
    integer tmpx = llSubStringIndex(value, mask);
    if(~tmpx) {
        integer diff = llStringLength(value) - llStringLength(mask);
        return  ((!tmpy && !diff)
             || ((tmpy == 1) && (tmpx == diff))
             || ((tmpy == 2) && !tmpx)
             ||  (tmpy == 3));
    }
    return FALSE;
}


//....................................................................
next() {
    ++gLine; // increase line count
    gQueryID = llGetNotecardLine(gName, gLine);   
}



//....................................................................
dbg(string msg) {
    if (debug) llOwnerSay(msg);
}

error(string txt) {
    llSetText(txt, <1,0,0>,1);
    llOwnerSay("ERROR: " + txt);
}
//____________________________________________________________________
//                         STATES
//....................................................................

default
{
    state_entry() {
        init();
        next();    // begin loading params from notecard
    }

    dataserver(key query_id, string data) {
        if (query_id == gQueryID) {                         // just checking the calling event is llGetNotecardLine()
            if (data != EOF) {                              // not at the end of the notecard
            
                //waiting for the first parameter (type of osTeleportAgent syntax
                if( like(data, "//%") || data == "") next();// ignore comments or emprt lines
                else {
                    contents = contents + [data];           // push entry to the list
                    dbg((string)gLine+": "+data);           // output the line           
                    next();                                 // request next line
                }
            }
            else loadSettings(); // notecard read, check syntax
        }
    }

    
    touch_start(integer num_detected) {
        
        avatarKey = llDetectedKey(0);
        dbg((string)avatarKey  + " - " +  (string)position + " - " + (string)lookAt);
        //return;
        llInstantMessage(avatarKey,"Teleporting to : " + TPdescription);
        if ( teleportType == 1) osTeleportAgent(avatarKey, destinationTarget, position, lookAt);
        else if (teleportType ==2) osTeleportAgent(avatarKey, regionX, regionY, position, lookAt);
        else if (teleportType ==3) osTeleportAgent(avatarKey, position, lookAt);
        else error("check the code");       
   
    }
    
    
    // Reload the notecard each time it's changed
    changed(integer change)
    {
        
        if (change & CHANGED_INVENTORY) { //notecard change
            gName = llGetInventoryName(INVENTORY_NOTECARD, 0);
            key tmp = llGetInventoryKey(gName);
            if (tmp != gUUID) {
                gUUID = tmp; // store UUID for next time
                dbg("Notecard updated : " + (string)change + " --> reloading");   
                init();
                next();
            }
        } 
    } 

}