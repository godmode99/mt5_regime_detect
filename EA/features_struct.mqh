#ifndef FEATURES_STRUCT_MQH
#define FEATURES_STRUCT_MQH

// Structure storing regime detection features
struct RegimeFeature
  {
   bool  bos;                   // Break of Structure detected
   int   trend_dir;             // Trend direction enum value
   bool  range_compression;     // Detect sideway compression/expansion
   bool  volume_spike;          // Volume spike confirmation
   bool  divergent;             // Volume divergence
   bool  sweep;                 // Liquidity sweep detected
   bool  ob_retest;             // Order Block retest/trap
   int   candle_strength;       // Candle momentum strength enum
   int   dir;                   // Candle direction enum
   int   session;               // Market session enum
   bool  news_flag;             // News flag presence
   // Multi‑timeframe signal placeholder
   int   mtf_signal;            // Cross TF signal value
  };

#endif // FEATURES_STRUCT_MQH
