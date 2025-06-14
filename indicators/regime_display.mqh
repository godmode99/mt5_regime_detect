#ifndef REGIME_DISPLAY_MQH
#define REGIME_DISPLAY_MQH

#include "regime_classifier.mqh"
#include "bos_detector.mqh"
#include "sweep_detector.mqh"
#include "volume_tools.mqh"
#include "ob_retest.mqh"
#include "candle_momentum.mqh"
#include "atr_tools.mqh"
#include "ma_slope.mqh"
#include "rsi_tools.mqh"

#ifdef REGIME_DISPLAY_INDICATOR

#property indicator_chart_window
#property indicator_buffers 0

input bool   InpShowLabels = true;                       // enable regime labels
input bool   InpPerBar     = false;                      // label each bar
input ENUM_BASE_CORNER InpCorner = CORNER_RIGHT_UPPER;   // corner for single label
input int    InpXOffset   = 10;                          // horizontal offset
input int    InpYOffset   = 20;                          // vertical offset

// map regime to string
string RegimeToString(RegimeType r)
  {
   switch(r)
     {
      case REGIME_UPTREND:         return "UPTREND";
      case REGIME_DOWNTREND:       return "DOWNTREND";
      case REGIME_STABLE_RANGE:    return "STABLE";
      case REGIME_VOLATILE_RANGE:  return "VOLATILE";
      case REGIME_BREAKOUT:        return "BREAKOUT";
      case REGIME_TRAP:            return "TRAP";
      case REGIME_DRIFT:           return "DRIFT";
      case REGIME_CHAOS:           return "CHAOS";
      default:                     return "UNKNOWN";
     }
  }

// map regime to display color
color RegimeToColor(RegimeType r)
  {
   switch(r)
     {
      case REGIME_UPTREND:         return clrLime;
      case REGIME_DOWNTREND:       return clrRed;
      case REGIME_STABLE_RANGE:    return clrGray;
      case REGIME_VOLATILE_RANGE:  return clrMagenta;
      case REGIME_BREAKOUT:        return clrDeepSkyBlue;
      case REGIME_TRAP:            return clrOrange;
      case REGIME_DRIFT:           return clrDodgerBlue;
      case REGIME_CHAOS:           return clrYellow;
      default:                     return clrWhite;
     }
  }

// minimal bars for calculations
#define REGIME_LOOKBACK  14
#define HISTORY_BARS     10

// classify regime at the given shift using indicator functions
RegimeType CalcRegime(const int shift)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   if(CopyRates(_Symbol,_Period,shift,REGIME_LOOKBACK+HISTORY_BARS,rates)<=0)
      return(REGIME_UNKNOWN);

   long volumes[];
   ArraySetAsSeries(volumes,true);
   if(CopyTickVolume(_Symbol,_Period,shift,REGIME_LOOKBACK+HISTORY_BARS,volumes)<=0)
      return(REGIME_UNKNOWN);

   RegimeFeature f;
   ResetRegimeFeature(f);

   f.atr      = CalcATR(rates,14);
   f.stddev   = CalcStdDev(rates,14);
   f.ma_slope = GetMASlope(rates,10);
   f.rsi      = GetRSI(rates,14);

   f.bos          = DetectBOS(rates,0);
   f.sweep        = DetectSweep(rates,0);
   f.volume_spike = DetectVolumeSpike(volumes,0);
   f.ob_retest    = DetectOBRetest(rates,0);
   f.candle_strength = GetCandleStrength(rates,0);

   f.range_compression = DetectRangeCompression(rates,HISTORY_BARS);
   f.divergent        = DetectVolumeDivergence(volumes,rates,0);
   f.trend_dir        = GetTrendDirection(rates,HISTORY_BARS);

   return(DetectRegime(f));
  }

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(!InpShowLabels)
      return(rates_total);

   int start = (prev_calculated==0) ? REGIME_LOOKBACK : prev_calculated-1;
   for(int bar=start; bar<rates_total-1; bar++)
     {
      RegimeType regime = CalcRegime(bar);
      string text = RegimeToString(regime);
      color c = RegimeToColor(regime);

      if(InpPerBar)
        {
         string name = StringFormat("regime_lbl_%d",bar);
         if(ObjectFind(0,name)<0)
            ObjectCreate(0,name,OBJ_TEXT,0,time[bar],high[bar]);
         ObjectSetString(0,name,OBJPROP_TEXT,text);
         ObjectSetInteger(0,name,OBJPROP_COLOR,c);
         ObjectSetDouble(0,name,OBJPROP_PRICE,high[bar]);
        }
      else if(bar==start)
        {
         string name="regime_current";
         if(ObjectFind(0,name)<0)
            ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
         ObjectSetString(0,name,OBJPROP_TEXT,text);
         ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpXOffset);
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpYOffset);
         ObjectSetInteger(0,name,OBJPROP_COLOR,c);
         ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrBlack);
        }
     }
   return(rates_total);
  }

#endif // REGIME_DISPLAY_INDICATOR

#endif // REGIME_DISPLAY_MQH
