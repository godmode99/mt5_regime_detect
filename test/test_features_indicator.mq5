#include "..\EA\features_struct.mqh"
#include "..\EA\ExportUtils.mqh"
#include "..\indicators\bos_detector.mqh"
#include "..\indicators\volume_tools.mqh"

//+------------------------------------------------------------------+
//| Helper assertion function                                        |
//+------------------------------------------------------------------+
void AssertEqual(bool expected, bool actual, string message)
  {
   if(expected == actual)
      Print("PASS: ", message);
   else
      PrintFormat("FAIL: %s expected=%d actual=%d", message, expected, actual);
  }

//+------------------------------------------------------------------+
//| Unit tests for BOS and VolumeSpike                                |
//+------------------------------------------------------------------+
int OnStart()
  {
   //--- Test DetectBOS when current bar breaks previous highs
   double high1[5] = {1.2200,1.2100,1.2050,1.2000,1.1950};
   double low1[5]  = {1.2100,1.2000,1.1950,1.1900,1.1850};
   bool bos_up = DetectBOS(high1, low1, 0, 3);          // expect true
   AssertEqual(true, bos_up, "DetectBOS - break above high");

   //--- Test DetectBOS when no break of structure occurs
   double high2[5] = {1.2100,1.2150,1.2200,1.2250,1.2300};
   double low2[5]  = {1.2000,1.2050,1.2100,1.2150,1.2200};
   bool bos_none = DetectBOS(high2, low2, 0, 3);        // expect false
   AssertEqual(false, bos_none, "DetectBOS - no break");

   //--- Test DetectVolumeSpike when current volume is a spike
   long volumes1[21] = {200,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100};
   bool spike_true = DetectVolumeSpike(volumes1, 0, 1.5); // expect true
   AssertEqual(true, spike_true, "DetectVolumeSpike - spike detected");

   //--- Test DetectVolumeSpike with normal volume levels
   long volumes2[21] = {100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100};
   bool spike_false = DetectVolumeSpike(volumes2, 0, 1.5); // expect false
   AssertEqual(false, spike_false, "DetectVolumeSpike - no spike");

   return(0);
  }
