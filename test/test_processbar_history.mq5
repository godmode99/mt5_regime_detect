#include "..\\EA\\RegimeMasterEA.mq5"

void AssertEqual(bool expected, bool actual, string message)
  {
   if(expected == actual)
      Print("PASS: ", message);
   else
      PrintFormat("FAIL: %s expected=%d actual=%d", message, expected, actual);
  }

void TestProcessBarInsufficientHistory()
  {
   RegimeFeature feature;
   // use large shift to simulate missing history
   ProcessBar(99999, feature);
   bool default_state = !feature.bos && feature.trend_dir==TREND_NONE && feature.mtf_signal==0;
   AssertEqual(true, default_state, "ProcessBar early exit on missing history");
  }

int OnStart()
  {
   Print("Running ProcessBar history test");
   TestProcessBarInsufficientHistory();
   return(0);
  }
