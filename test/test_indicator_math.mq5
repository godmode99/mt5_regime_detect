#include "..\\EA\\features_struct.mqh"
#include "..\\indicators\\atr_tools.mqh"
#include "..\\indicators\\ma_slope.mqh"
#include "..\\indicators\\rsi_tools.mqh"

void AssertEqual(bool expected,bool actual,string msg)
{
   if(expected==actual)
      Print("PASS: ",msg);
   else
      PrintFormat("FAIL: %s expected=%d actual=%d",msg,expected,actual);
}

void TestCalcATR()
{
   MqlRates r[3];
   ArraySetAsSeries(r,true);
   r[0].high=1.2; r[0].low=1.1; r[0].close=1.15;
   r[1].high=1.19; r[1].low=1.11; r[1].close=1.14;
   r[2].high=1.18; r[2].low=1.12; r[2].close=1.13;
   double atr=CalcATR(r,2);
   bool ok=MathAbs(atr-0.085)<=0.0001;
   AssertEqual(true,ok,"CalcATR basic");
}

void TestCalcStdDev()
{
   MqlRates r[4];
   ArraySetAsSeries(r,true);
   r[0].close=1.0; r[1].close=1.1; r[2].close=0.9; r[3].close=1.0;
   double sd=CalcStdDev(r,3);
   bool ok=MathAbs(sd-0.1000)<=0.001;
   AssertEqual(true,ok,"CalcStdDev basic");
}

void TestGetMASlope()
{
   MqlRates r[4];
   ArraySetAsSeries(r,true);
   r[0].close=5; r[1].close=4; r[2].close=3; r[3].close=2;
   double slope=GetMASlope(r,2);
   bool ok=MathAbs(slope-2.0)<=0.0001;
   AssertEqual(true,ok,"GetMASlope basic");
}

void TestGetRSI()
{
   MqlRates r[5];
   ArraySetAsSeries(r,true);
   r[0].close=12; r[1].close=11; r[2].close=10; r[3].close=9; r[4].close=8;
   double rsi=GetRSI(r,3);
   bool ok=MathAbs(rsi-100.0)<=0.1;
   AssertEqual(true,ok,"GetRSI strong trend");
}

int OnStart()
{
   Print("Running indicator math tests");
   TestCalcATR();
   TestCalcStdDev();
   TestGetMASlope();
   TestGetRSI();
   return 0;
}
