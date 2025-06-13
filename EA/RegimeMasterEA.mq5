#include "features_struct.mqh"           // struct definition for RegimeFeature
#include "ExportUtils.mqh"               // helpers for CSV/JSON export
#include "..\indicators\bos_detector.mqh"     // Break of Structure detection
#include "..\indicators\sweep_detector.mqh"   // Liquidity sweep detection
#include "..\indicators\volume_tools.mqh"     // Volume spike/divergence tools
#include "..\indicators\ob_retest.mqh"        // Order Block retest detector
#include "..\indicators\candle_momentum.mqh"  // Candle strength/direction tools
#include "..\indicators\session_tools.mqh"    // Session and news utilities

#include "..\indicators\mtf_signal.mqh"        // Multi time frame signal
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
   //--- process logic only when a new bar is formed
   datetime bar_time = iTime(_Symbol,_Period,0);
   if(bar_time==g_last_bar_time)
      return;                       // exit until new bar is formed

   g_last_bar_time = bar_time;

   //--- gather regime features for a window of recent bars
   for(int shift=1; shift<=HISTORY_BARS; shift++)
     {
      RegimeFeature feature;
      ProcessBar(shift,feature);   // fill feature struct for this bar

      //--- store result in buffer for batch export
      g_feature_buffer[g_feature_index] = feature;
      g_feature_index++;

      //--- export buffer to CSV when EXPORT_INTERVAL rows collected
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

   //--- populate a few core fields using indicator modules
   feature.bos          = DetectBOS(rates,0);              // break of structure
   feature.sweep        = DetectSweep(rates,0);            // liquidity sweep
   feature.volume_spike = DetectVolumeSpike(volumes,0);    // volume spike
   feature.ob_retest    = DetectOBRetest(rates,0);         // order block retest
   feature.candle_strength = GetCandleStrength(rates,0);   // candle momentum
   feature.session      = GetMarketSession(rates[shift].time); // session context

   feature.range_compression = DetectRangeCompression(rates,HISTORY_BARS); // detect sideway compression
   feature.divergent        = DetectVolumeDivergence(volumes,rates,0);     // check volume divergence
   feature.trend_dir        = GetTrendDirection(rates,HISTORY_BARS);       // overall trend direction
   feature.dir              = GetCandleDirection(rates,0);                 // candle direction
   feature.news_flag        = IsNewsEvent(rates[shift].time);              // flag news events
   feature.mtf_signal       = GetMTFSignal(rates,HISTORY_BARS);            // multi time frame signal
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
   // delegate to ExportToCSV for single row export
   ExportToCSV(arr,"data\\exported_features.csv");
  }

