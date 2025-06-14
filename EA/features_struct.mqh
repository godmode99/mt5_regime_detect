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
   datetime       time;              // bar time
   string         symbol;            // trading symbol
   double         open;              // open price
   double         high;              // high price
   double         low;               // low price
   double         close;             // close price
   long           tick_volume;       // tick volume
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
   //--- reset time and price fields
   feature.time        = 0;
   feature.symbol      = "";
   feature.open        = 0.0;
   feature.high        = 0.0;
   feature.low         = 0.0;
   feature.close       = 0.0;
   feature.tick_volume = 0;
   //--- clear boolean fields
   feature.bos              = false;           // reset Break of Structure flag
   feature.range_compression= false;           // reset compression/expansion flag
   feature.volume_spike     = false;           // reset volume spike confirmation
   feature.divergent        = false;           // reset volume divergence flag
   feature.sweep            = false;           // reset liquidity sweep flag
   feature.ob_retest        = false;           // reset order block retest flag
   feature.news_flag        = false;           // reset news event indicator

   //--- reset enumeration fields
   feature.trend_dir        = TREND_NONE;      // reset trend direction
   feature.candle_strength  = STRENGTH_NONE;   // reset candle momentum strength
   feature.dir              = DIR_NONE;        // reset candle direction
   feature.session          = SESSION_UNKNOWN; // reset market session

   //--- reset numeric fields
   feature.mtf_signal       = 0;               // reset multi time frame signal
  }

//+------------------------------------------------------------------+
//| Convert RegimeFeature to CSV string                              |
//| input:  feature - struct with calculated values                  |
//| output: csvRow - string reference to receive CSV result          |
//+------------------------------------------------------------------+
void FeatureToCSV(const RegimeFeature &feature,string &csvRow)
  {
   /*
      Serialize all struct fields into a comma separated string.
     Each boolean or enumeration is cast to int so the CSV contains
      only numeric values. Order of fields matches data_dictionary.md
      and ExportUtils.mqh:
      time,symbol,open,high,low,close,tick_volume,
      bos,trend_dir,range_compression,volume_spike,divergent,
      sweep,ob_retest,candle_strength,dir,session,news_flag,mtf_signal
      Example row: "1623495600,EURUSD,1.1000,1.1050,1.0980,1.1020,150,1,0,0,1,0,0,1,2,1,3,0,5".
   */

   csvRow  = IntegerToString((int)feature.time)             + ","   // bar time
            + feature.symbol                                + ","   // trading symbol
            + DoubleToString(feature.open,_Digits)          + ","   // open price
            + DoubleToString(feature.high,_Digits)          + ","   // high price
            + DoubleToString(feature.low,_Digits)           + ","   // low price
            + DoubleToString(feature.close,_Digits)         + ","   // close price
            + IntegerToString((int)feature.tick_volume)     + ","   // tick volume
            + IntegerToString((int)feature.bos)             + ","   // Break of Structure
            + IntegerToString((int)feature.trend_dir)       + ","   // Trend direction
            + IntegerToString((int)feature.range_compression)+ ","  // Range compression
            + IntegerToString((int)feature.volume_spike)    + ","   // Volume spike
            + IntegerToString((int)feature.divergent)       + ","   // Volume divergence
            + IntegerToString((int)feature.sweep)           + ","   // Liquidity sweep
            + IntegerToString((int)feature.ob_retest)       + ","   // Order Block retest
            + IntegerToString((int)feature.candle_strength) + ","   // Candle momentum
            + IntegerToString((int)feature.dir)             + ","   // Candle direction
            + IntegerToString((int)feature.session)         + ","   // Market session
            + IntegerToString((int)feature.news_flag)       + ","   // News flag
            + IntegerToString(feature.mtf_signal);               // MTF signal
  }

#endif // FEATURES_STRUCT_MQH
