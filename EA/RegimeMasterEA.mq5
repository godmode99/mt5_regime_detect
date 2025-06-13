#include "features_struct.mqh"
#include "ExportUtils.mqh"
#include "..\indicators\bos_detector.mqh"
#include "..\indicators\sweep_detector.mqh"
#include "..\indicators\volume_tools.mqh"
#include "..\indicators\ob_retest.mqh"
#include "..\indicators\candle_momentum.mqh"
#include "..\indicators\session_tools.mqh"

//+------------------------------------------------------------------+
//| Constants and global storage                                     |
//+------------------------------------------------------------------+
#define EXPORT_INTERVAL 100                 // export after N feature rows
#define HISTORY_BARS    10                  // number of historical bars to process

// buffer storing features before export
RegimeFeature g_feature_buffer[];
int           g_feature_index = 0;          // current buffer index
datetime      g_last_bar_time = 0;          // time of last processed bar

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- reset counters on EA initialization
   g_feature_index = 0;
   g_last_bar_time = 0;
   //--- allocate dynamic feature buffer
   ArrayResize(g_feature_buffer,EXPORT_INTERVAL);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- export any remaining features on shutdown
   if(g_feature_index>0)
     {
      ArrayResize(g_feature_buffer,g_feature_index);
      ExportToCSV(g_feature_buffer,"data\\exported_features.csv");
      g_feature_index = 0;
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- process once per new completed bar
   datetime bar_time = iTime(_Symbol,_Period,0);
   if(bar_time==g_last_bar_time)
      return;                       // exit until new bar is formed

   g_last_bar_time = bar_time;

   //--- gather features for recent HISTORY_BARS closed bars
   for(int shift=1; shift<=HISTORY_BARS; shift++)
     {
      RegimeFeature feature;
      ProcessBar(shift,feature);

      //--- store in buffer for batch export
      g_feature_buffer[g_feature_index] = feature;
      g_feature_index++;

      //--- export once buffer becomes full
      if(g_feature_index>=EXPORT_INTERVAL)
        {
         ExportToCSV(g_feature_buffer,"data\\exported_features.csv");
         g_feature_index = 0;
        }
     }
  }

//+------------------------------------------------------------------+
//| Process current bar and fill feature struct                      |
//| input:  shift   - bar shift to analyze                           |
//|         feature - struct to populate with values                 |
//| output: none                                                     |
//+------------------------------------------------------------------+
void ProcessBar(const int shift, RegimeFeature &feature)
  {
   //--- reset all fields before calculation
   ResetRegimeFeature(feature);

   //--- gather required history arrays
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   CopyRates(_Symbol,_Period,shift,50,rates);

   long volumes[];
   ArraySetAsSeries(volumes,true);
   CopyTickVolume(_Symbol,_Period,shift,50,volumes);

   //--- calculate selected example features
   feature.bos          = DetectBOS(rates,shift);
   feature.sweep        = DetectSweep(rates,shift);
   feature.volume_spike = DetectVolumeSpike(volumes,shift);

   //--- other fields would be filled here in a full implementation
  }

//+------------------------------------------------------------------+
//| Export collected features after validation                       |
//| input:  feature - calculated feature struct                      |
//| output: none                                                     |
//+------------------------------------------------------------------+
void ExportCurrentFeature(const RegimeFeature &feature)
  {
   RegimeFeature arr[1];
   arr[0]=feature;
   ExportToCSV(arr,"data\\exported_features.csv");
  }
