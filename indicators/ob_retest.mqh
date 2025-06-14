#ifndef OB_RETEST_MQH
#define OB_RETEST_MQH

//+------------------------------------------------------------------+
//| Detect Order Block retest or trap                                |
//| input:  rates[] - price series                                    |
//|         shift   - bar index to evaluate                           |
//| output: true if retest pattern found                              |
//+------------------------------------------------------------------+
bool DetectOBRetest(const MqlRates rates[], const int shift)
  {
   if(shift+1>=ArraySize(rates))
      return(false);
   double prev_high=rates[shift+1].high;
   double prev_low =rates[shift+1].low;
   bool down_retest=(rates[shift].high>prev_high && rates[shift].close<prev_high);
   bool up_retest  =(rates[shift].low <prev_low  && rates[shift].close>prev_low);
   return(down_retest||up_retest);
  }

//+------------------------------------------------------------------+
//| Identify potential trap areas                                    |
//| input:  rates[] - price series                                    |
//|         bars    - analysis window                                 |
//| output: true if trap zone detected                                |
//+------------------------------------------------------------------+
bool DetectTrapZone(const MqlRates rates[], const int bars)
  {
   if(bars<=0 || ArraySize(rates)<=bars)
      return(false);
   double max_high=rates[1].high;
   double min_low =rates[1].low;
   for(int i=2;i<=bars;i++)
     {
      if(rates[i].high>max_high) max_high=rates[i].high;
      if(rates[i].low <min_low)  min_low =rates[i].low;
     }
   double range=max_high-min_low;
   if(range<=0.0)
      return(false);
   double threshold=range*0.2;
  return(rates[0].close>max_high-threshold || rates[0].close<min_low+threshold);
  }

#ifdef OB_RETEST_OVERLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 0

input color InpOBRectColor = clrOrange;  // rectangle color
input int   InpOBRectWidth = 1;          // rectangle border width

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
   int start=(prev_calculated==0)?1:prev_calculated-1;
   for(int bar=start; bar<rates_total-1; bar++)
     {
      double prev_high=high[bar+1];
      double prev_low =low[bar+1];
      bool down_retest=(high[bar]>prev_high && close[bar]<prev_high);
      bool up_retest  =(low[bar]<prev_low  && close[bar]>prev_low);
      if(down_retest || up_retest)
        {
         string rect=StringFormat("ob_rect_%d",bar);
         if(ObjectFind(0,rect)<0)
            ObjectCreate(0,rect,OBJ_RECTANGLE,0,time[bar+1],prev_low,time[bar],prev_high);
         else
            ObjectMove(0,rect,0,time[bar+1],prev_low);
         ObjectMove(0,rect,1,time[bar],prev_high);
         ObjectSetInteger(0,rect,OBJPROP_COLOR,InpOBRectColor);
         ObjectSetInteger(0,rect,OBJPROP_WIDTH,InpOBRectWidth);

         string arrow=StringFormat("ob_retest_%d",bar);
         if(ObjectFind(0,arrow)<0)
            ObjectCreate(0,arrow,OBJ_ARROW,0,time[bar],close[bar]);
         ObjectSetInteger(0,arrow,OBJPROP_COLOR,InpOBRectColor);
         ObjectSetDouble(0,arrow,OBJPROP_PRICE,close[bar]);
        }
     }
   return(rates_total);
  }

#endif // OB_RETEST_OVERLAY_INDICATOR

#endif // OB_RETEST_MQH
