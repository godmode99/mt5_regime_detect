#include "..\\EA\\features_struct.mqh"
#include "..\\indicators\\regime_classifier.mqh"

void AssertEqual(int expected,int actual,string message)
  {
   if(expected==actual)
      Print("PASS: ",message);
   else
      PrintFormat("FAIL: %s expected=%d actual=%d",message,expected,actual);
  }

void TestDetectRegime()
  {
   RegimeFeature f;
   ResetRegimeFeature(f);

   // uptrend
   f.trend_dir=TREND_UP;
   f.range_compression=false;
   AssertEqual(REGIME_UPTREND,DetectRegime(f),"DetectRegime uptrend");

   // downtrend
   ResetRegimeFeature(f);
   f.trend_dir=TREND_DOWN;
   AssertEqual(REGIME_DOWNTREND,DetectRegime(f),"DetectRegime downtrend");

   // stable range
   ResetRegimeFeature(f);
   f.range_compression=true;
   f.volume_spike=false;
   AssertEqual(REGIME_STABLE_RANGE,DetectRegime(f),"DetectRegime stable range");

   // volatile range
   ResetRegimeFeature(f);
   f.range_compression=true;
   f.volume_spike=true;
   AssertEqual(REGIME_VOLATILE_RANGE,DetectRegime(f),"DetectRegime volatile range");

  // breakout
  ResetRegimeFeature(f);
  f.bos=true;
  f.sweep=false;
  f.ma_slope=1.0;
  f.rsi=70;
  AssertEqual(REGIME_BREAKOUT,DetectRegime(f),"DetectRegime breakout");

   // trap
   ResetRegimeFeature(f);
   f.ob_retest=true;
   AssertEqual(REGIME_TRAP,DetectRegime(f),"DetectRegime trap");

  // drift
  ResetRegimeFeature(f);
  f.trend_dir=TREND_NONE;
  f.candle_strength=STRENGTH_NONE;
  f.volume_spike=false;
  f.atr=0.0005;
  f.stddev=0.002;
  AssertEqual(REGIME_DRIFT,DetectRegime(f),"DetectRegime drift");

  // chaos
  ResetRegimeFeature(f);
  f.bos=true;
  f.sweep=true;
  f.volume_spike=true;
  f.atr=0.02;
  f.stddev=0.005;
  AssertEqual(REGIME_CHAOS,DetectRegime(f),"DetectRegime chaos");

   // unknown
   ResetRegimeFeature(f);
   AssertEqual(REGIME_UNKNOWN,DetectRegime(f),"DetectRegime unknown");
  }

int OnStart()
  {
   Print("Running regime classifier tests");
   TestDetectRegime();
   return(0);
  }
