//
//  ScriptFreeMem
//
// Author : Witestar Magic
// Profile : http://forums.osgrid.org/memberlist.php?mode=viewprofile&u=1793&sid=ce9ac2b072bdbbba72f7696f5e3c6822

string FreeMem()
{
//float mempct = (100 * llGetFreeMemory() / (float)(16*1024)); // for non-MONO
float mempct = (100 * llGetFreeMemory() / (float)(64*1024)); // for MONO
string percent = llGetSubString((string)mempct,0,4); // displays 75.25%
string memtmpA = (string)(llGetFreeMemory()/1024)+"k ("+percent+"%)";
return memtmpA;
}
