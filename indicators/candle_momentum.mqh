#ifndef CANDLE_MOMENTUM_MQH
#define CANDLE_MOMENTUM_MQH

#include "..\\EA\\features_struct.mqh"

//+------------------------------------------------------------------+
//| Calculate candle momentum strength                               |
//| input:  rates[] - price series                                    |
//|         shift   - bar index                                       |
//| output: CandleStrength value                                      |
//+------------------------------------------------------------------+
CandleStrength GetCandleStrength(const MqlRates &rates[], const int shift)
  {
   if(shift>=ArraySize(rates))
      return(STRENGTH_NONE);

   double body=MathAbs(rates[shift].close - rates[shift].open);
   double range=rates[shift].high - rates[shift].low;
   if(range<=0.0)
      return(STRENGTH_NONE);

   double ratio=body/range;
   if(ratio>0.6)
      return(STRENGTH_STRONG);
   if(ratio>0.3)
      return(STRENGTH_WEAK);
   return(STRENGTH_NONE);
  }

//+------------------------------------------------------------------+
//| Determine candle direction (bull/bear)                           |
//| input:  rates[] - price series                                    |
//|         shift   - bar index                                       |
//| output: CandleDirection value                                     |
//+------------------------------------------------------------------+
CandleDirection GetCandleDirection(const MqlRates &rates[], const int shift)
  {
   if(shift>=ArraySize(rates))
      return(DIR_NONE);
   double diff=rates[shift].close - rates[shift].open;
   if(diff>0)
      return(DIR_BULL);
   if(diff<0)
      return(DIR_BEAR);
   return(DIR_NONE);
  }

#ifdef CANDLE_MOMENTUM_OVERLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 0

input color  InpStrongColor = clrLime;        // arrow color for strong candles
input color  InpWeakColor   = clrOrange;      // arrow color for weak candles
input ENUM_ARROW_SYMBOL InpBullArrow = SYMBOL_ARROWUP;   // bull direction icon
input ENUM_ARROW_SYMBOL InpBearArrow = SYMBOL_ARROWDOWN; // bear direction icon
input bool   InpShowWeak   = true;           // display weak candles
input bool   InpShowStrong = true;           // display strong candles
input double InpYOffset    = 0.0;            // vertical offset in price

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int start=(prev_calculated==0)?0:prev_calculated-1;
   for(int bar=start; bar<rates_total; bar++)
     {
      double body=MathAbs(close[bar]-open[bar]);
      double range=high[bar]-low[bar];
      CandleStrength strength=STRENGTH_NONE;
      if(range>0.0)
        {
         double ratio=body/range;
         if(ratio>0.6)
            strength=STRENGTH_STRONG;
         else if(ratio>0.3)
            strength=STRENGTH_WEAK;
        }
      if(strength==STRENGTH_NONE)
         continue;
      if(strength==STRENGTH_WEAK && !InpShowWeak)
         continue;
      if(strength==STRENGTH_STRONG && !InpShowStrong)
         continue;

      double diff=close[bar]-open[bar];
      CandleDirection dir=DIR_NONE;
      if(diff>0) dir=DIR_BULL;
      else if(diff<0) dir=DIR_BEAR;
      if(dir==DIR_NONE)
         continue;

      string name=StringFormat("cm_arrow_%d",bar);
      ENUM_ARROW_SYMBOL arrow=(dir==DIR_BULL)?InpBullArrow:InpBearArrow;
      color c=(strength==STRENGTH_STRONG)?InpStrongColor:InpWeakColor;
      double price=high[bar]+InpYOffset;
      if(ObjectFind(0,name)<0)
         ObjectCreate(0,name,OBJ_ARROW,0,time[bar],price);
      ObjectSetInteger(0,name,OBJPROP_ARROWCODE,arrow);
      ObjectSetInteger(0,name,OBJPROP_COLOR,c);
      ObjectSetDouble(0,name,OBJPROP_PRICE,price);
     }
   return(rates_total);
  }

#endif // CANDLE_MOMENTUM_OVERLAY_INDICATOR

#endif // CANDLE_MOMENTUM_MQH
