#ifndef VOLUME_TOOLS_MQH
#define VOLUME_TOOLS_MQH

//+------------------------------------------------------------------+
//| Detect volume spike confirmation                                 |
//| input:  volumes[] - array of volume data                          |
//|         shift     - bar index                                     |
//| output: true if spike detected                                    |
//+------------------------------------------------------------------+
bool DetectVolumeSpike(const long volumes[], const int shift)
  {
   return(DetectVolumeSpike(volumes,shift,1.5));
  }

//+------------------------------------------------------------------+
//| Detect volume divergence                                         |
//| input:  volumes[] - volume series                                 |
//|         prices[]  - corresponding price data                      |
//|         shift     - bar index                                     |
//| output: true if divergence found                                  |
//+------------------------------------------------------------------+
bool DetectVolumeDivergence(const long volumes[], const MqlRates &prices[], const int shift)
  {
   if(shift+1>=ArraySize(volumes) || shift+1>=ArraySize(prices))
      return(false);
   double price_delta=prices[shift].close - prices[shift+1].close;
   long   vol_delta=volumes[shift] - volumes[shift+1];
   return((price_delta>0 && vol_delta<0) || (price_delta<0 && vol_delta>0));
  }

//+------------------------------------------------------------------+
//| Detect volume spike using lookback average                       |
//| input:  volumes[] - volume series                                |
//|         bar       - bar index to evaluate                        |
//|         threshold - spike multiplier                              |
//| output: true if spike detected                                   |
//+------------------------------------------------------------------+
bool DetectVolumeSpike(const long &volumes[],   // volume data
                       const int   bar,         // bar index to check
                       const double threshold = 1.5)  // spike factor
  {
   //--- set lookback window length
   const int window = 20;

   //--- ensure enough history exists for average calculation
   if(bar + window >= ArraySize(volumes))
      return(false);

   //--- accumulate volume of prior bars in the window
   double sum = 0.0;
   for(int i = bar + 1; i <= bar + window; i++)
      sum += volumes[i];

   //--- compute average volume over lookback window
   double avg_vol = sum / window;

   //--- spike detected if current volume exceeds threshold * average
   return(volumes[bar] > avg_vol * threshold);
  }

//+------------------------------------------------------------------+
//| Detect volume spike from MqlRates series                         |
//| input:  rates[] - array of price data containing tick_volume     |
//|         bars    - number of bars to analyze                      |
//| output: true if spike detected on the current bar                |
//| usage:  DetectVolumeSpike(rates,bars)                            |
//+------------------------------------------------------------------+
bool DetectVolumeSpike(const MqlRates &rates[], const int bars)
  {
   //--- validate history length
   if(bars<=0 || ArraySize(rates)<=bars)
      return(false);

   //--- build temporary volume array from rates
   long volumes[];
   ArraySetAsSeries(volumes,true);
   ArrayResize(volumes,bars+1);
   for(int i=0;i<=bars && i<ArraySize(rates);i++)
      volumes[i]=rates[i].tick_volume;

   //--- delegate to main volume spike logic
   return(DetectVolumeSpike(volumes,0,1.5));
  }

#endif // VOLUME_TOOLS_MQH
