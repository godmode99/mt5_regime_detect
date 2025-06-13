#ifndef MTF_TOOLS_MQH
#define MTF_TOOLS_MQH

#include "bos_detector.mqh"
#include "volume_tools.mqh"

//+------------------------------------------------------------------+
//| Calculate aggregated multi time frame signal                     |
//| input:  htf[] - higher timeframe rates (e.g. H1)                  |
//|         ltf[] - lower timeframe rates (e.g. M5)                   |
//|         bars  - number of bars for trend evaluation              |
//| output: bit mask signal                                          |
//+------------------------------------------------------------------+
int AggregateMTFSignal(const MqlRates htf[], const MqlRates ltf[], const int bars)
  {
   if(ArraySize(htf)<=bars || ArraySize(ltf)<=bars)
      return(0);

   //--- BOS on higher timeframe
   bool bos_htf = DetectBOS(htf,0);

   //--- Trend direction from higher timeframe using lookback 'bars'
   double start = htf[bars].close;
   double end   = htf[0].close;
   TrendDirection dir = TREND_NONE;
   if(end>start)
      dir = TREND_UP;
   else if(end<start)
      dir = TREND_DOWN;

   //--- volume spike on lower timeframe
   long ltf_volumes[];
   ArraySetAsSeries(ltf_volumes,true);
   ArrayResize(ltf_volumes,bars+1);
   for(int i=0;i<=bars && i<ArraySize(ltf);i++)
      ltf_volumes[i] = ltf[i].tick_volume;

   bool volume_spike_lf = DetectVolumeSpike(ltf_volumes,0);

   //--- combine results using bit mask
   int signal = 0;
   if(bos_htf)
      signal |= 1;
   if(dir==TREND_UP)
      signal |= 2;
   if(volume_spike_lf)
      signal |= 4;

   return(signal);
  }

#endif // MTF_TOOLS_MQH
