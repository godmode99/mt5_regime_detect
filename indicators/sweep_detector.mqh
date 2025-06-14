#ifndef SWEEP_DETECTOR_MQH
#define SWEEP_DETECTOR_MQH

//+------------------------------------------------------------------+
//| Detect liquidity sweep or fake breakout                          |
//| input:  rates[] - array of price data                             |
//|         shift   - bar index to evaluate                           |
//| output: true if sweep pattern detected                            |
//+------------------------------------------------------------------+
bool DetectSweep(const MqlRates &rates[], const int shift)
  {
   if(shift>=ArraySize(rates))
      return(false);
   double atr=rates[shift].high - rates[shift].low;
   double upper=rates[shift].high - rates[shift].close;
   double lower=rates[shift].close - rates[shift].low;
   double limit=atr*0.5; // 50% of ATR
   return(upper>limit || lower>limit);
  }

//+------------------------------------------------------------------+
//| Check for range compression / expansion                          |
//| input:  rates[] - price series                                    |
//|         bars    - bars to evaluate                                |
//| output: true if compression detected                              |
//+------------------------------------------------------------------+
bool DetectRangeCompression(const MqlRates &rates[], const int bars)
  {
   if(bars<=0 || ArraySize(rates)<=bars)
      return(false);
   double max_high=rates[0].high;
   double min_low =rates[0].low;
   for(int i=1;i<bars;i++)
     {
      if(rates[i].high>max_high) max_high=rates[i].high;
      if(rates[i].low <min_low)  min_low =rates[i].low;
     }
   double range=max_high-min_low;
    double curr=rates[0].high - rates[0].low;
    return(curr<range*0.5);
  }

//+------------------------------------------------------------------+
//| Detect sweep on the latest bar across provided rates             |
//| input:  rates[] - price series                                   |
//|         bars    - number of bars to analyze                      |
//| output: true if sweep condition detected                         |
//+------------------------------------------------------------------+
bool DetectSweep(const MqlRates &rates[], const int bars)
  {
   //--- validate array size against requested lookback
   if(bars<=0 || ArraySize(rates)<=bars)
      return(false);

   //--- extract price components and simple ATR approximation
   double high[];
   double low[];
   double close[];
   double atr[];
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(atr,true);
   ArrayResize(high,bars+1);
   ArrayResize(low,bars+1);
   ArrayResize(close,bars+1);
   ArrayResize(atr,bars+1);
   for(int i=0;i<=bars && i<ArraySize(rates);i++)
     {
      high[i]=rates[i].high;
      low[i] =rates[i].low;
      close[i]=rates[i].close;
      atr[i]  =rates[i].high - rates[i].low;
     }

   //--- delegate to general sweep detector with 50% wick threshold
   return(DetectSweep(high,low,close,atr,0,50.0));
  }

//+------------------------------------------------------------------+
//| Detect sweep using wick vs ATR threshold                         |
//| input:  high[]   - array of high prices                          |
//|         low[]    - array of low prices                           |
//|         close[]  - array of close prices                         |
//|         atr[]    - ATR values                                    |
//|         bar      - bar index to evaluate                         |
//|         wick_threshold - wick size percent of ATR                |
//| output: true if wick exceeds threshold                           |
//+------------------------------------------------------------------+
bool DetectSweep(const double &high[],   // high price series
                 const double &low[],    // low price series
                 const double &close[],  // close price series
                 const double &atr[],    // ATR values
                 const int     bar,      // bar to check
                 const double  wick_threshold)
  {
   //--- ensure arrays contain the requested bar
   if(bar >= ArraySize(high) || bar >= ArraySize(low) ||
      bar >= ArraySize(close) || bar >= ArraySize(atr))
      return(false);                       // insufficient history

   //--- calculate upper and lower wick lengths
   double upper_wick = high[bar] - close[bar];  // distance from close to high
   double lower_wick = close[bar] - low[bar];   // distance from low to close

   //--- convert threshold percent of ATR to absolute value
   double limit = atr[bar] * wick_threshold / 100.0;

   //--- sweep detected if either wick exceeds the limit
   return(upper_wick > limit || lower_wick > limit);
  }

#ifdef SWEEP_DETECTOR_OVERLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 0

input color InpSweepColor      = clrDeepSkyBlue;   // vertical line color
input ENUM_ARROW_SYMBOL InpSweepSymbol = SYMBOL_THINVERT; // marker symbol
input double InpYOffset       = 0.0;               // vertical offset for marker

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
   for(int bar=start; bar<rates_total-1; bar++)
     {
      double atr = high[bar]-low[bar];
      double upper = high[bar]-close[bar];
      double lower = close[bar]-low[bar];
      double limit = atr*0.5;
      if(upper>limit || lower>limit)
        {
         string line=StringFormat("sweep_vline_%d",bar);
         if(ObjectFind(0,line)<0)
            ObjectCreate(0,line,OBJ_VLINE,0,time[bar],0);
         ObjectSetInteger(0,line,OBJPROP_COLOR,InpSweepColor);
         ObjectSetInteger(0,line,OBJPROP_WIDTH,1);
         double pct = (atr>0.0)?MathMax(upper,lower)/atr*100.0:0.0;
         string tip = StringFormat("wick %.1f%% / ATR %.5f",pct,atr);
         ObjectSetString(0,line,OBJPROP_TOOLTIP,tip);

         string mark=StringFormat("sweep_mark_%d",bar);
         if(ObjectFind(0,mark)<0)
            ObjectCreate(0,mark,OBJ_ARROW,0,time[bar],high[bar]+InpYOffset);
         ObjectSetInteger(0,mark,OBJPROP_ARROWCODE,InpSweepSymbol);
         ObjectSetInteger(0,mark,OBJPROP_COLOR,InpSweepColor);
         ObjectSetDouble(0,mark,OBJPROP_PRICE,high[bar]+InpYOffset);
         ObjectSetString(0,mark,OBJPROP_TOOLTIP,tip);
        }
     }
   return(rates_total);
  }

#endif // SWEEP_DETECTOR_OVERLAY_INDICATOR

#endif // SWEEP_DETECTOR_MQH
