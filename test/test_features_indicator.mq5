#include "..\\EA\\features_struct.mqh"
#include "..\\EA\\ExportUtils.mqh"
#include "..\\indicators\\bos_detector.mqh"
#include "..\\indicators\\volume_tools.mqh"
#include "..\\indicators\\sweep_detector.mqh"

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
//| Test DetectBOS                                                   |
//+------------------------------------------------------------------+
void TestDetectBOS()
  {
   // positive case: bar0 breaks above prior highs -> expect true
   double high1[5] = {1.2200,1.2100,1.2050,1.2000,1.1950};
   double low1[5]  = {1.2100,1.2000,1.1950,1.1900,1.1850};
   bool bos_up = DetectBOS(high1, low1, 0, 3);
   AssertEqual(true, bos_up, "DetectBOS - break above high");

   // negative case: no break of structure -> expect false
   double high2[5] = {1.2100,1.2150,1.2200,1.2250,1.2300};
   double low2[5]  = {1.2000,1.2050,1.2100,1.2150,1.2200};
   bool bos_none = DetectBOS(high2, low2, 0, 3);
   AssertEqual(false, bos_none, "DetectBOS - no break");
  }

//+------------------------------------------------------------------+
//| Test DetectVolumeSpike                                           |
//+------------------------------------------------------------------+
void TestDetectVolumeSpike()
  {
   // positive case: first bar volume double the average -> expect true
   long volumes1[21] = {200,100,100,100,100,100,100,100,100,100,100,100,100,100,
                        100,100,100,100,100,100,100};
   bool spike_true = DetectVolumeSpike(volumes1, 0, 1.5);
   AssertEqual(true, spike_true, "DetectVolumeSpike - spike detected");

   // negative case: uniform volumes -> expect false
   long volumes2[21] = {100,100,100,100,100,100,100,100,100,100,100,100,100,100,
                        100,100,100,100,100,100,100};
   bool spike_false = DetectVolumeSpike(volumes2, 0, 1.5);
   AssertEqual(false, spike_false, "DetectVolumeSpike - no spike");
  }

//+------------------------------------------------------------------+
//| Test DetectSweep                                                 |
//+------------------------------------------------------------------+
void TestDetectSweep()
  {
   // positive case: upper wick greater than 50% ATR -> expect true
   double high1[1]  = {1.2100};
   double low1[1]   = {1.1900};
   double close1[1] = {1.1950};
   double atr1[1]   = {0.0200};
   bool sweep_true = DetectSweep(high1, low1, close1, atr1, 0, 50.0);
   AssertEqual(true, sweep_true, "DetectSweep - long wick");

   // negative case: wicks within half ATR -> expect false
   double high2[1]  = {1.2100};
   double low2[1]   = {1.2060};
   double close2[1] = {1.2080};
   double atr2[1]   = {0.0040};
   bool sweep_false = DetectSweep(high2, low2, close2, atr2, 0, 50.0);
   AssertEqual(false, sweep_false, "DetectSweep - small wicks");
  }

//+------------------------------------------------------------------+
//| Entry point to execute all tests                                 |
//+------------------------------------------------------------------+
int OnStart()
  {
   Print("Running indicator unit tests");
   TestDetectBOS();
   TestDetectVolumeSpike();
   TestDetectSweep();
   return(0);
  }

