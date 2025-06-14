#include "..\\EA\\features_struct.mqh"
#include "..\\EA\\ExportUtils.mqh"
#include "..\\indicators\\bos_detector.mqh"
#include "..\\indicators\\volume_tools.mqh"
#include "..\\indicators\\sweep_detector.mqh"
#include "..\\indicators\\mtf_signal.mqh"
#include "..\\indicators\\mtf_tools.mqh"
#include "..\\indicators\\atr_tools.mqh"
#include "..\\indicators\\ma_slope.mqh"
#include "..\\indicators\\rsi_tools.mqh"

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
//| Test GetMTFSignal                                                |
//+------------------------------------------------------------------+
void TestGetMTFSignal()
  {
   const int bars = 3;

   // prepare deterministic higher timeframe (H1) data
   MqlRates htf[21];
   MqlRates ltf[21];
   ArraySetAsSeries(htf,true);
   ArraySetAsSeries(ltf,true);

   for(int i=0; i<21; i++)
     {
      htf[i].high        = 1.1000 + i*0.0010;
      htf[i].low         = 1.0900 + i*0.0010;
      htf[i].close       = 1.0950 + i*0.0010;
      htf[i].tick_volume = 100;

      ltf[i].high        = 1.1000 + i*0.0002;
      ltf[i].low         = 1.0990 - i*0.0002;
      ltf[i].close       = 1.0995 + i*0.0002;
      ltf[i].tick_volume = (i==0 ? 200 : 100); // spike on latest bar
     }

   // induce break of structure and uptrend on H1
   htf[0].high  = 1.2000;
   htf[0].close = 1.1950;

   // base timeframe rates (reuse htf for simplicity)
   MqlRates rates[4];
   ArraySetAsSeries(rates,true);
   for(int i=0;i<4;i++)
      rates[i] = htf[i];

   // expected bit mask from direct aggregation
   int expected = AggregateMTFSignal(htf, ltf, bars);
   int actual   = GetMTFSignal(rates, bars);

  AssertEqual(true, expected==actual, "GetMTFSignal - cross timeframe signal");
 }

//+------------------------------------------------------------------+
//| Test CalcATR and CalcStdDev                                      |
//+------------------------------------------------------------------+
void TestATRStdDev()
  {
   MqlRates r[4];
   ArraySetAsSeries(r,true);
   r[0].high=1.20; r[0].low=1.10; r[0].close=1.15;
   r[1].high=1.18; r[1].low=1.12; r[1].close=1.14;
   r[2].high=1.19; r[2].low=1.11; r[2].close=1.13;
   r[3].high=1.18; r[3].low=1.10; r[3].close=1.12;
   double atr = CalcATR(r,2);
   double stddev = CalcStdDev(r,3);
   bool atr_ok = MathAbs(atr-0.08)<0.0001;
   bool std_ok = MathAbs(stddev-0.011547)<0.001;
   AssertEqual(true, atr_ok, "CalcATR basic");
   AssertEqual(true, std_ok, "CalcStdDev basic");
  }

//+------------------------------------------------------------------+
//| Test GetMASlope and GetRSI                                       |
//+------------------------------------------------------------------+
void TestMASlopeRSI()
  {
   MqlRates r[5];
   ArraySetAsSeries(r,true);
   r[0].close=12; r[1].close=11; r[2].close=10; r[3].close=9; r[4].close=8;
   double slope = GetMASlope(r,2);
   bool slope_ok = MathAbs(slope-2.0)<0.0001;
   MqlRates rsiRates[5];
   ArraySetAsSeries(rsiRates,true);
   rsiRates[0].close=1.2; rsiRates[1].close=1.1; rsiRates[2].close=1.0; rsiRates[3].close=0.9; rsiRates[4].close=0.8;
   double rsi = GetRSI(rsiRates,3);
   bool rsi_ok = MathAbs(rsi-100.0)<0.1;
   AssertEqual(true, slope_ok, "GetMASlope positive");
   AssertEqual(true, rsi_ok, "GetRSI uptrend");
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
  TestGetMTFSignal();
  TestATRStdDev();
  TestMASlopeRSI();
  return(0);
  }

