#ifndef REGIME_CLASSIFIER_MQH
#define REGIME_CLASSIFIER_MQH

#include "..\\EA\\features_struct.mqh"

//+------------------------------------------------------------------+
//| Classify current market regime based on feature values            |
//| input:  feature - calculated RegimeFeature                        |
//| output: RegimeType enumeration value                              |
//+------------------------------------------------------------------+
RegimeType DetectRegime(const RegimeFeature &feature)
  {
   if(feature.ob_retest)
      return(REGIME_TRAP);
   if(feature.bos && feature.sweep && feature.volume_spike)
      return(REGIME_CHAOS);
   if(feature.bos && !feature.sweep)
      return(REGIME_BREAKOUT);
   if(feature.range_compression && feature.volume_spike)
      return(REGIME_VOLATILE_RANGE);
   if(feature.range_compression && !feature.volume_spike)
      return(REGIME_STABLE_RANGE);
   if(feature.trend_dir==TREND_UP && !feature.range_compression)
      return(REGIME_UPTREND);
   if(feature.trend_dir==TREND_DOWN && !feature.range_compression)
      return(REGIME_DOWNTREND);
   if(feature.candle_strength==STRENGTH_NONE && !feature.volume_spike && feature.trend_dir==TREND_NONE)
      return(REGIME_DRIFT);
   return(REGIME_UNKNOWN);
  }

#endif // REGIME_CLASSIFIER_MQH
