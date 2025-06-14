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

#ifdef BOS_OVERLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

input int   InpBOSWindow      = 3;           // lookback bars for swings
input color InpSwingColor     = clrSilver;   // color for swing lines
input color InpArrowUpColor   = clrLime;     // color for BOS up arrow
input color InpArrowDownColor = clrRed;      // color for BOS down arrow
input int   InpArrowUpCode    = 233;         // arrow symbol for BOS up
input int   InpArrowDownCode  = 234;         // arrow symbol for BOS down

//+------------------------------------------------------------------+
//| Helper to draw swing lines                                       |
//+------------------------------------------------------------------+
void DrawSwingLines(const string prefix,const datetime t,const double hi,const double lo)
  {
   string name_hi=prefix+"_hi"+IntegerToString((int)t);
   string name_lo=prefix+"_lo"+IntegerToString((int)t);
   if(ObjectFind(0,name_hi)<0)
     {
      ObjectCreate(0,name_hi,OBJ_HLINE,0,t,hi);
      ObjectSetInteger(0,name_hi,OBJPROP_COLOR,InpSwingColor);
     }
   if(ObjectFind(0,name_lo)<0)
     {
      ObjectCreate(0,name_lo,OBJ_HLINE,0,t,lo);
      ObjectSetInteger(0,name_lo,OBJPROP_COLOR,InpSwingColor);
     }
  }

//+------------------------------------------------------------------+
//| Helper to draw BOS arrow                                         |
//+------------------------------------------------------------------+
void DrawBOSArrow(const string prefix,const datetime t,const double price,const bool up)
  {
   string name=prefix+"_arrow"+IntegerToString((int)t);
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_ARROW,0,t,price);
      ObjectSetInteger(0,name,OBJPROP_COLOR,up?InpArrowUpColor:InpArrowDownColor);
      ObjectSetInteger(0,name,OBJPROP_ARROWCODE,up?InpArrowUpCode:InpArrowDownCode);
     }
  }

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
   int start=prev_calculated==0 ? InpBOSWindow : prev_calculated-1;
   for(int i=start;i<rates_total-InpBOSWindow;i++)
     {
      double prev_high=high[i+1];
      double prev_low =low[i+1];
      for(int j=i+2;j<=i+InpBOSWindow && j<rates_total;j++)
        {
         if(high[j]>prev_high) prev_high=high[j];
         if(low[j] <prev_low)  prev_low =low[j];
        }

      bool bos_up   = high[i] > prev_high;
      bool bos_down = low[i]  < prev_low;

      string prefix="bos"+IntegerToString(i);
      DrawSwingLines(prefix,time[i],prev_high,prev_low);
      if(bos_up)
         DrawBOSArrow(prefix,time[i],high[i],true);
      if(bos_down)
         DrawBOSArrow(prefix,time[i],low[i],false);
     }
   return(rates_total);
  }

void OnDeinit(const int reason)
  {
   for(int i=ObjectsTotal()-1;i>=0;i--)
     {
      string name=ObjectName(i);
      if(StringFind(name,"bos")==0)
         ObjectDelete(0,name);
     }
  }

#endif // BOS_OVERLAY_INDICATOR

#endif // BOS_DETECTOR_MQH
