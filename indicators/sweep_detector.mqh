#ifndef SWEEP_DETECTOR_MQH
#define SWEEP_DETECTOR_MQH

//+------------------------------------------------------------------+
//| Detect liquidity sweep or fake breakout                          |
//| input:  rates[] - array of price data                             |
//|         shift   - bar index to evaluate                           |
//| output: true if sweep pattern detected                            |
//+------------------------------------------------------------------+
bool DetectSweep(const MqlRates rates[], const int shift);

//+------------------------------------------------------------------+
//| Check for range compression / expansion                          |
//| input:  rates[] - price series                                    |
//|         bars    - bars to evaluate                                |
//| output: true if compression detected                              |
//+------------------------------------------------------------------+
bool DetectRangeCompression(const MqlRates rates[], const int bars);

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

#endif // SWEEP_DETECTOR_MQH
