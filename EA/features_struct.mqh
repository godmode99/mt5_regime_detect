#ifndef FEATURES_STRUCT_MQH
#define FEATURES_STRUCT_MQH

//+------------------------------------------------------------------+
//| Enumerations for regime feature fields                           |
//+------------------------------------------------------------------+
enum TrendDirection
  {
   TREND_NONE = 0,   // No clear trend
   TREND_UP,         // Uptrend detected
   TREND_DOWN        // Downtrend detected
  };

enum CandleStrength
  {
   STRENGTH_NONE = 0,   // No momentum
   STRENGTH_WEAK,
   STRENGTH_STRONG
  };

enum CandleDirection
  {
   DIR_NONE = 0,
   DIR_BULL,
   DIR_BEAR
  };

enum MarketSession
  {
   SESSION_UNKNOWN = 0,
   SESSION_ASIA,
   SESSION_EUROPE,
   SESSION_US
  };

//+------------------------------------------------------------------+
//| Structure storing regime detection features                      |
//+------------------------------------------------------------------+
struct RegimeFeature
  {
   bool           bos;                // Break of Structure flag
   TrendDirection trend_dir;          // Trend direction enumeration
   bool           range_compression;  // Sideway compression/expansion flag
   bool           volume_spike;       // Volume spike confirmation
   bool           divergent;          // Volume divergence flag
   bool           sweep;              // Liquidity sweep/fake breakout
   bool           ob_retest;          // Order Block retest/trap flag
   CandleStrength candle_strength;    // Candle momentum strength
   CandleDirection dir;               // Candle direction
   MarketSession  session;            // Market session context
   bool           news_flag;          // News event flag
   int            mtf_signal;         // Multi time frame cross-check signal
  };

//+------------------------------------------------------------------+
//| Reset all fields in RegimeFeature to default values              |
//| input:  feature - struct to reset                                |
//| output: none                                                     |
//+------------------------------------------------------------------+
void ResetRegimeFeature(RegimeFeature &feature);

//+------------------------------------------------------------------+
//| Convert RegimeFeature to CSV string                              |
//| input:  feature - struct with calculated values                  |
//| output: CSV formatted string                                     |
//+------------------------------------------------------------------+
string FeatureToCSV(const RegimeFeature &feature);

#endif // FEATURES_STRUCT_MQH
