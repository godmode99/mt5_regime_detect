#ifndef MTF_SIGNAL_MQH
#define MTF_SIGNAL_MQH

//+------------------------------------------------------------------+
//| Calculate multi time frame signal                                |
//| input:  rates[] - price series                                   |
//|         bars    - number of bars to analyze                      |
//| output: integer signal code                                      |
//+------------------------------------------------------------------+
int GetMTFSignal(const MqlRates rates[], const int bars)
  {
   //--- gather higher and lower timeframe data
   MqlRates htf[];                     // H1 timeframe for broader trend/BOS
   MqlRates ltf[];                     // M5 timeframe for volume confirmation

   ArraySetAsSeries(htf,true);
   ArraySetAsSeries(ltf,true);

   // CopyRates returns number of elements copied; we request bars+1 to
   // align index 0 with the latest bar across timeframes
   int copied_htf = CopyRates(_Symbol,PERIOD_H1,0,bars+1,htf);
   int copied_ltf = CopyRates(_Symbol,PERIOD_M5,0,bars+1,ltf);

   // if history is missing fall back to neutral signal
   if(copied_htf<=0 || copied_ltf<=0 || ArraySize(rates)<=bars)
      return(0);

   //--- indicator checks on different timeframes
   bool bos_htf         = DetectBOS(htf,0);             // BOS on H1
   TrendDirection dir   = GetTrendDirection(htf,bars);  // trend from H1
   bool volume_spike_lf = DetectVolumeSpike(ltf,0);     // volume spike on M5

   //--- combine results using a simple bit mask
   // bit0 -> BOS detected on H1
   // bit1 -> Uptrend on H1
   // bit2 -> Volume spike on M5
   int signal = 0;
   if(bos_htf)
      signal |= 1;
   if(dir==TREND_UP)
      signal |= 2;
   if(volume_spike_lf)
      signal |= 4;

   return(signal);
  }

#endif // MTF_SIGNAL_MQH
