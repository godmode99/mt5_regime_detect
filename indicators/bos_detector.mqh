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

#endif // BOS_DETECTOR_MQH
