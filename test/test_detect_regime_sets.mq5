#include "..\\EA\\features_struct.mqh"
#include "..\\indicators\\regime_classifier.mqh"

void AssertEqual(int expected,int actual,string message)
{
   if(expected==actual)
      Print("PASS: ",message);
   else
      PrintFormat("FAIL: %s expected=%d actual=%d",message,expected,actual);
}

void TestDetectRegimeWithSets()
{
   RegimeFeature sets[8];
   for(int i=0;i<8;i++)
      ResetRegimeFeature(sets[i]);

   sets[0].trend_dir=TREND_UP;                                     // UPTREND
   sets[1].trend_dir=TREND_DOWN;                                   // DOWNTREND
   sets[2].range_compression=true;                                 // STABLE_RANGE
   sets[3].range_compression=true; sets[3].volume_spike=true;      // VOLATILE_RANGE
   sets[4].bos=true; sets[4].ma_slope=1.0; sets[4].rsi=70;         // BREAKOUT
   sets[5].ob_retest=true;                                         // TRAP
   sets[6].candle_strength=STRENGTH_NONE; sets[6].volume_spike=false; sets[6].trend_dir=TREND_NONE; sets[6].atr=0.0005; sets[6].stddev=0.002; // DRIFT
   sets[7].bos=true; sets[7].sweep=true; sets[7].volume_spike=true; sets[7].atr=0.02; sets[7].stddev=0.005; // CHAOS

   int expected[8];
   expected[0]=REGIME_UPTREND;
   expected[1]=REGIME_DOWNTREND;
   expected[2]=REGIME_STABLE_RANGE;
   expected[3]=REGIME_VOLATILE_RANGE;
   expected[4]=REGIME_BREAKOUT;
   expected[5]=REGIME_TRAP;
   expected[6]=REGIME_DRIFT;
   expected[7]=REGIME_CHAOS;

   for(int i=0;i<8;i++)
   {
      int actual=DetectRegime(sets[i]);
      string msg=StringFormat("DetectRegime set %d",i);
      AssertEqual(expected[i],actual,msg);
   }
}

int OnStart()
{
   Print("Running DetectRegime set tests");
   TestDetectRegimeWithSets();
   return 0;
}
