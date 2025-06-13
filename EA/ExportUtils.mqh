#ifndef EXPORT_UTILS_MQH
#define EXPORT_UTILS_MQH

#include <Files\Csv.mqh>
#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| Export RegimeFeature data to CSV file                            |
//| input:  feature - calculated feature struct                      |
//| output: none                                                     |
//+------------------------------------------------------------------+
void ExportFeatureCSV(const RegimeFeature &feature);

//+------------------------------------------------------------------+
//| Export RegimeFeature data to JSON file                           |
//| input:  feature - calculated feature struct                      |
//| output: none                                                     |
//+------------------------------------------------------------------+
void ExportFeatureJSON(const RegimeFeature &feature);

//+------------------------------------------------------------------+
//| Validate fields before exporting                                 |
//| input:  feature - struct with values to check                    |
//| output: true if all fields are valid                             |
//+------------------------------------------------------------------+
bool ValidateFeature(const RegimeFeature &feature);

//+------------------------------------------------------------------+
//| Write single feature struct to default CSV path                  |
//+------------------------------------------------------------------+
void ExportFeatureCSV(const RegimeFeature &feature)
  {
   RegimeFeature arr[1];
   arr[0]=feature;
   ExportToCSV(arr,"data\\exported_features.csv");
  }

//+------------------------------------------------------------------+
//| Export feature struct to JSON file                                |
//+------------------------------------------------------------------+
void ExportFeatureJSON(const RegimeFeature &feature)
  {
   string json=StringFormat("{\"bos\":%d,\"trend_dir\":%d,\"range_compression\":%d,\"volume_spike\":%d,\"divergent\":%d,\"sweep\":%d,\"ob_retest\":%d,\"candle_strength\":%d,\"dir\":%d,\"session\":%d,\"news_flag\":%d,\"mtf_signal\":%d}",
                           (int)feature.bos,
                           (int)feature.trend_dir,
                           (int)feature.range_compression,
                           (int)feature.volume_spike,
                           (int)feature.divergent,
                           (int)feature.sweep,
                           (int)feature.ob_retest,
                           (int)feature.candle_strength,
                           (int)feature.dir,
                           (int)feature.session,
                           (int)feature.news_flag,
                           feature.mtf_signal);
   int handle=FileOpen("data\\exported_features.json",FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_APPEND);
   if(handle!=INVALID_HANDLE)
     {
      FileWrite(handle,json);
      FileClose(handle);
     }
  }

//+------------------------------------------------------------------+
//| Basic validation of feature values                                |
//+------------------------------------------------------------------+
bool ValidateFeature(const RegimeFeature &feature)
  {
   if(feature.trend_dir < TREND_NONE || feature.trend_dir > TREND_DOWN)
      return(false);
   if(feature.candle_strength < STRENGTH_NONE || feature.candle_strength > STRENGTH_STRONG)
      return(false);
   if(feature.dir < DIR_NONE || feature.dir > DIR_BEAR)
      return(false);
   if(feature.session < SESSION_UNKNOWN || feature.session > SESSION_US)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//| Export array of RegimeFeature structs to CSV file                |
//| input:  features[] - array of calculated features                |
//|         filename   - path to write CSV data                      |
//| output: none                                                     |
//|                                                                  |
//| The CSV format uses a header row followed by numeric values.     |
//| Sample row: "1,0,0,1,0,0,1,2,1,3,0,5"                            |
//+------------------------------------------------------------------+
void ExportToCSV(RegimeFeature &features[], const string filename)
  {
   //--- attempt to open file for writing as CSV
   int handle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;                       // stop if file cannot be opened

   //--- write CSV header matching data_dictionary.md
   FileWrite(handle,
             "bos,trend_dir,range_compression,volume_spike,divergent,"
             "sweep,ob_retest,candle_strength,dir,session,news_flag,mtf_signal");

   //--- iterate over feature array and output each struct as CSV row
   int total = ArraySize(features);
   for(int i=0;i<total;i++)
     {
      const RegimeFeature &f = features[i];

      // write all fields as integer values in the defined order
      FileWrite(handle,
                (int)f.bos,
                (int)f.trend_dir,
                (int)f.range_compression,
                (int)f.volume_spike,
                (int)f.divergent,
                (int)f.sweep,
                (int)f.ob_retest,
                (int)f.candle_strength,
                (int)f.dir,
                (int)f.session,
                (int)f.news_flag,
                f.mtf_signal);
     }

   //--- close the file after writing all rows
   FileClose(handle);
  }

#endif // EXPORT_UTILS_MQH
