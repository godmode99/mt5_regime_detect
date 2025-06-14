#ifndef BOS_DETECTOR_MQH
#define BOS_DETECTOR_MQH

//+------------------------------------------------------------------+
//| Return true if Break of Structure detected on given bar          |
//| input:  rates[] - array of price data                             |
//|         shift   - bar index to evaluate                           |
//| output: true if BOS pattern found                                 |
//+------------------------------------------------------------------+
bool DetectBOS(const MqlRates rates[], const int shift)
  {
   const int window = 3;
   if(shift + window >= ArraySize(rates))
      return(false);

   double prev_high = rates[shift+1].high;
   double prev_low  = rates[shift+1].low;
   for(int i=shift+2;i<=shift+window;i++)
     {
      if(rates[i].high > prev_high)
         prev_high = rates[i].high;
      if(rates[i].low < prev_low)
         prev_low = rates[i].low;
     }

   bool bos_up   = rates[shift].high > prev_high;
   bool bos_down = rates[shift].low  < prev_low;
  return(bos_up || bos_down);
  }

//+------------------------------------------------------------------+
//| Detect Break of Structure on current bar using lookback window   |
//| input:  rates[] - price series                                   |
//|         bars    - number of previous bars to check               |
//| output: true if BOS pattern detected                             |
//+------------------------------------------------------------------+
bool DetectBOS(const MqlRates rates[], const int bars)
  {
   //--- ensure enough bars are available
   if(bars<=0 || ArraySize(rates)<=bars)
      return(false);

   //--- prepare temporary high/low arrays for generic detector
   double high[];
   double low[];
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArrayResize(high,bars+1);
   ArrayResize(low,bars+1);
   for(int i=0;i<=bars && i<ArraySize(rates);i++)
     {
      high[i]=rates[i].high;
      low[i] =rates[i].low;
     }

   //--- call main BOS logic using extracted arrays
   return(DetectBOS(high,low,0,bars));
  }

//+------------------------------------------------------------------+
//| Detect Break of Structure using high/low arrays                  |
//| input:  high[]  - array of high prices                           |
//|         low[]   - array of low prices                            |
//|         bar     - bar index to evaluate                          |
//|         window  - number of previous bars to check               |
//| output: true if BOS detected                                     |
//+------------------------------------------------------------------+
bool DetectBOS(const double &high[],  // high price series
               const double &low[],   // low price series
               const int     bar,     // bar to evaluate
               const int     window)  // lookback window size
  {
   //--- validate sufficient history is available
   if(bar + window >= ArraySize(high))        // check array bounds
      return(false);                          // not enough data

   //--- initialize previous swing levels from next bar
   double prev_high = high[bar + 1];          // starting swing high
   double prev_low  = low[bar + 1];           // starting swing low

   //--- scan back to find highest high and lowest low in window
   for(int i = bar + 2; i <= bar + window; i++)
     {
      if(high[i] > prev_high)
         prev_high = high[i];                // update higher high
      if(low[i] < prev_low)
         prev_low = low[i];                  // update lower low
     }

   //--- determine break of structure conditions
   bool bos_up   = high[bar] > prev_high;    // break above swing high
   bool bos_down = low[bar]  < prev_low;     // break below swing low

   //--- BOS detected when either side is broken
   return(bos_up || bos_down);               // final result
  }

//+------------------------------------------------------------------+
//| Determine trend direction based on recent swings                 |
//| input:  rates[] - array of price data                             |
//|         bars    - number of bars to analyze                       |
//| output: TrendDirection enumeration value                          |
//+------------------------------------------------------------------+
TrendDirection GetTrendDirection(const MqlRates rates[], const int bars)
  {
   if(bars<=0 || ArraySize(rates)<=bars)
      return(TREND_NONE);

   double start=rates[bars].close;
   double end=rates[0].close;
   if(end>start)
      return(TREND_UP);
   if(end<start)
      return(TREND_DOWN);
   return(TREND_NONE);
  }

#ifdef BOS_DETECTOR_OVERLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 0

input color InpBOSLineColor  = clrSilver;       // swing level line color
input color InpBOSArrowColor = clrRed;          // BOS arrow color
input ENUM_ARROW_SYMBOL InpBOSArrow = SYMBOL_ARROWUP; // arrow style
input int   InpBOSLookback   = 3;               // lookback bars for swing

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
   int start = (prev_calculated==0) ? InpBOSLookback : prev_calculated-1;
   for(int bar=start; bar<rates_total-1; bar++)
     {
      // calculate swing levels
      double prev_high = high[bar+1];
      double prev_low  = low[bar+1];
      for(int i=bar+2; i<=bar+InpBOSLookback && i<rates_total; i++)
        {
         if(high[i] > prev_high)
            prev_high = high[i];
         if(low[i]  < prev_low)
            prev_low = low[i];
        }

      // draw horizontal lines
      string name_high = StringFormat("bos_high_%d", bar);
      if(ObjectFind(0,name_high)<0)
         ObjectCreate(0,name_high,OBJ_HLINE,0,time[bar],prev_high);
      ObjectSetDouble(0,name_high,OBJPROP_PRICE,prev_high);
      ObjectSetInteger(0,name_high,OBJPROP_COLOR,InpBOSLineColor);

      string name_low = StringFormat("bos_low_%d", bar);
      if(ObjectFind(0,name_low)<0)
         ObjectCreate(0,name_low,OBJ_HLINE,0,time[bar],prev_low);
      ObjectSetDouble(0,name_low,OBJPROP_PRICE,prev_low);
      ObjectSetInteger(0,name_low,OBJPROP_COLOR,InpBOSLineColor);

      // draw arrow when BOS detected
      if(DetectBOS(high, low, bar, InpBOSLookback))
        {
         string arrow_name = StringFormat("bos_arrow_%d", bar);
         double price = (high[bar] > prev_high) ? high[bar] : low[bar];
         if(ObjectFind(0,arrow_name)<0)
            ObjectCreate(0,arrow_name,OBJ_ARROW,0,time[bar],price);
         ObjectSetInteger(0,arrow_name,OBJPROP_ARROWCODE,InpBOSArrow);
         ObjectSetInteger(0,arrow_name,OBJPROP_COLOR,InpBOSArrowColor);
         ObjectSetDouble(0,arrow_name,OBJPROP_PRICE,price);
        }
     }
   return(rates_total);
  }

#endif // BOS_DETECTOR_OVERLAY_INDICATOR

#endif // BOS_DETECTOR_MQH
