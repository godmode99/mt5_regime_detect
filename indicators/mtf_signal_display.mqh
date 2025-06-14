#ifndef MTF_SIGNAL_DISPLAY_MQH
#define MTF_SIGNAL_DISPLAY_MQH

#include "mtf_signal.mqh"

#ifdef MTF_SIGNAL_DISPLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 0

input int   InpBars        = 10;                      // lookback bars
input ENUM_BASE_CORNER InpCorner = CORNER_RIGHT_UPPER; // display corner
input int   InpXOffset    = 10;                      // horizontal offset
input int   InpYOffset    = 20;                      // vertical offset
input color InpBgColor    = clrBlack;                // background color
input color InpTextColor  = clrWhite;                // text color

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
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   if(CopyRates(_Symbol,_Period,0,InpBars+1,rates)<=0)
      return(0);

   int signal = GetMTFSignal(rates,InpBars);

   string name="mtf_signal_box";
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);

   string text=StringFormat("MTF signal: %d",signal);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpXOffset);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpYOffset);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpTextColor);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,InpBgColor);

   return(rates_total);
  }

#endif // MTF_SIGNAL_DISPLAY_INDICATOR

#endif // MTF_SIGNAL_DISPLAY_MQH
