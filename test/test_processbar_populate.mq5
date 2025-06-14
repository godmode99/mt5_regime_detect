// Mock CopyRates and CopyTickVolume before including EA
MqlRates g_main[60];
MqlRates g_htf[60];
MqlRates g_ltf[60];
long     g_vols[60];

int MyCopyRates(string symbol,ENUM_TIMEFRAMES tf,int start_pos,int count,MqlRates& dest[])
{
   if(tf==PERIOD_H1)
   {
      ArrayResize(dest,count); for(int i=0;i<count;i++) dest[i]=g_htf[start_pos+i];
      return count;
   }
   if(tf==PERIOD_M5)
   {
      ArrayResize(dest,count); for(int i=0;i<count;i++) dest[i]=g_ltf[start_pos+i];
      return count;
   }
   ArrayResize(dest,count); for(int i=0;i<count;i++) dest[i]=g_main[start_pos+i];
   return count;
}

int MyCopyTickVolume(string symbol,ENUM_TIMEFRAMES tf,int start_pos,int count,long& dest[])
{
   ArrayResize(dest,count); for(int i=0;i<count;i++) dest[i]=g_vols[start_pos+i];
   return count;
}

#define CopyRates MyCopyRates
#define CopyTickVolume MyCopyTickVolume
#include "..\\EA\\RegimeMasterEA.mq5"

void AssertEqual(bool expected,bool actual,string message)
{
   if(expected==actual)
      Print("PASS: ",message);
   else
      PrintFormat("FAIL: %s expected=%d actual=%d",message,expected,actual);
}

void PrepareMockData()
{
   for(int i=0;i<60;i++)
   {
      double base=1.0 + i*0.01;
      g_main[i].time = 1000-i*60;
      g_main[i].open = base;
      g_main[i].high = base+0.01;
      g_main[i].low  = base-0.01;
      g_main[i].close= base+0.005;
      g_main[i].tick_volume=100+i;
      g_htf[i]=g_main[i];
      g_ltf[i]=g_main[i];
      g_vols[i]=100+i;
   }
}

void TestProcessBarPopulate()
{
   PrepareMockData();
   RegimeFeature f;
   ProcessBar(0,f);
   double atr=CalcATR(g_main,14);
   double stddev=CalcStdDev(g_main,14);
   double slope=GetMASlope(g_main,10);
   double rsi=GetRSI(g_main,14);
   bool atr_ok=MathAbs(f.atr-atr)<=0.0001;
   bool std_ok=MathAbs(f.stddev-stddev)<=0.0001;
   bool slope_ok=MathAbs(f.ma_slope-slope)<=0.0001;
   bool rsi_ok=MathAbs(f.rsi-rsi)<=0.0001;
   AssertEqual(true,atr_ok,"ProcessBar ATR populated");
   AssertEqual(true,std_ok,"ProcessBar StdDev populated");
   AssertEqual(true,slope_ok,"ProcessBar MA slope populated");
   AssertEqual(true,rsi_ok,"ProcessBar RSI populated");
}

int OnStart()
{
   Print("Running ProcessBar populate test");
   TestProcessBarPopulate();
   return 0;
}
