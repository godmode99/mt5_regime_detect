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
void ResetRegimeFeature(RegimeFeature &feature)
  {
   //--- clear all boolean flags
   feature.bos              = false;           // Break of Structure
   feature.range_compression= false;           // Compression/expansion state
   feature.volume_spike     = false;           // Volume spike confirmation
   feature.divergent        = false;           // Volume divergence
   feature.sweep            = false;           // Liquidity sweep detected
   feature.ob_retest        = false;           // Order block retest flag
   feature.news_flag        = false;           // News event flag

   //--- reset enumeration values
   feature.trend_dir        = TREND_NONE;      // Unknown trend direction
   feature.candle_strength  = STRENGTH_NONE;   // No candle momentum
   feature.dir              = DIR_NONE;        // Candle direction
   feature.session          = SESSION_UNKNOWN; // Market session context

   //--- reset numeric fields
   feature.mtf_signal       = 0;               // Multi time frame signal
  }

//+------------------------------------------------------------------+
//| Convert RegimeFeature to CSV string                              |
//| input:  feature - struct with calculated values                  |
//| output: csvRow - string reference to receive CSV result          |
//+------------------------------------------------------------------+
void FeatureToCSV(const RegimeFeature &feature,string &csvRow)
  {
   /*
      Convert each field to an integer and build a comma separated
      row. The field order follows docs/data_dictionary.md and matches
      ExportUtils.mqh. Example row: "1,0,0,1,0,0,1,2,1,3,0,5".
   */

  csvRow = IntegerToString((int)feature.bos)              + "," +
            IntegerToString((int)feature.trend_dir)        + "," +
            IntegerToString((int)feature.range_compression)+ "," +
            IntegerToString((int)feature.volume_spike)     + "," +
            IntegerToString((int)feature.divergent)        + "," +
            IntegerToString((int)feature.sweep)            + "," +
            IntegerToString((int)feature.ob_retest)        + "," +
            IntegerToString((int)feature.candle_strength)  + "," +
            IntegerToString((int)feature.dir)              + "," +
            IntegerToString((int)feature.session)          + "," +
            IntegerToString((int)feature.news_flag)        + "," +
            IntegerToString(feature.mtf_signal);
  }

//+------------------------------------------------------------------+
//| Convert RegimeFeature to CSV string                              |
//| input:  feature - struct with calculated values                  |
//| output: csvRow - string reference to receive CSV result          |
//+------------------------------------------------------------------+
void FeatureToCSV(const RegimeFeature &feature, string &csvRow);

#endif // FEATURES_STRUCT_MQH
