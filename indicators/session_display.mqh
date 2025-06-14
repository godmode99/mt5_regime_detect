#ifndef SESSION_DISPLAY_MQH
#define SESSION_DISPLAY_MQH

#include "session_tools.mqh"

#ifdef SESSION_DISPLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 0

input color InpAsiaColor   = clrAliceBlue;   // Asia session color
input color InpEuropeColor = clrLavender;    // Europe session color
input color InpUSColor     = clrMistyRose;   // US session color
input int   InpFillAlpha   = 25;             // rectangle transparency 0-255
input color InpNewsColor   = clrGold;        // news icon color
input ENUM_ARROW_SYMBOL InpNewsSymbol = SYMBOL_RIGHTPRICE; // news symbol
input double InpNewsYOffset = 0.0;           // vertical offset for news icon

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
   int start = (prev_calculated==0) ? 0 : prev_calculated-1;
   double chart_min = ChartGetDouble(0,CHART_PRICE_MIN);
   double chart_max = ChartGetDouble(0,CHART_PRICE_MAX);

   for(int bar=start; bar<rates_total-1; bar++)
     {
      MarketSession session = GetMarketSession(time[bar]);
      color fill;
      if(session==SESSION_ASIA)
         fill = ColorToARGB(InpAsiaColor,InpFillAlpha);
      else if(session==SESSION_EUROPE)
         fill = ColorToARGB(InpEuropeColor,InpFillAlpha);
      else if(session==SESSION_US)
         fill = ColorToARGB(InpUSColor,InpFillAlpha);
      else
         continue;

      string rect = StringFormat("session_rect_%d",bar);
      if(ObjectFind(0,rect)<0)
         ObjectCreate(0,rect,OBJ_RECTANGLE,0,time[bar+1],chart_min,time[bar],chart_max);
      else
        {
         ObjectMove(0,rect,0,time[bar+1],chart_min);
         ObjectMove(0,rect,1,time[bar],chart_max);
        }
      ObjectSetInteger(0,rect,OBJPROP_COLOR,fill);
      ObjectSetInteger(0,rect,OBJPROP_BACK,true);
      ObjectSetInteger(0,rect,OBJPROP_FILL,true);
      ObjectSetInteger(0,rect,OBJPROP_WIDTH,1);

      if(IsNewsEvent(time[bar]))
        {
         string name = StringFormat("news_icon_%d",bar);
         double price = chart_max + InpNewsYOffset;
         if(ObjectFind(0,name)<0)
            ObjectCreate(0,name,OBJ_ARROW,0,time[bar],price);
         ObjectSetInteger(0,name,OBJPROP_ARROWCODE,InpNewsSymbol);
         ObjectSetInteger(0,name,OBJPROP_COLOR,InpNewsColor);
         ObjectSetDouble(0,name,OBJPROP_PRICE,price);
        }
     }
   return(rates_total);
  }

#endif // SESSION_DISPLAY_INDICATOR

#endif // SESSION_DISPLAY_MQH
