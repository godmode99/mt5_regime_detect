#ifndef VOLUME_DISPLAY_MQH
#define VOLUME_DISPLAY_MQH

#include "volume_tools.mqh"

#ifdef VOLUME_DISPLAY_INDICATOR

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_label1  "Volume"

input double InpSpikeThreshold = 1.5;         // volume spike multiplier
input color  InpDefaultColor   = clrGray;     // normal bar color
input color  InpSpikeColor     = clrRed;      // spike bar color
input color  InpDivergeColor   = clrDeepPink; // divergence bar color

double g_vol_buffer[];
color  g_color_buffer[];

int OnInit()
  {
   SetIndexBuffer(0,g_vol_buffer,INDICATOR_DATA);
   SetIndexBuffer(1,g_color_buffer,INDICATOR_COLOR_INDEX);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_HISTOGRAM);
   PlotIndexSetString(0,PLOT_LABEL,"Volume");
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
   int start = (prev_calculated==0) ? 0 : prev_calculated-1;
   for(int bar=start; bar<rates_total-1; bar++)
     {
      g_vol_buffer[bar] = (double)tick_volume[bar];
      g_color_buffer[bar] = InpDefaultColor;

      bool spike = DetectVolumeSpike(tick_volume, bar, InpSpikeThreshold);
      bool div   = false;
      if(bar+1 < rates_total)
        {
         double price_delta = close[bar] - close[bar+1];
         long   vol_delta   = tick_volume[bar] - tick_volume[bar+1];
         div = ((price_delta>0 && vol_delta<0) || (price_delta<0 && vol_delta>0));
        }
      if(div)
         g_color_buffer[bar] = InpDivergeColor;
      else if(spike)
         g_color_buffer[bar] = InpSpikeColor;
     }
   return(rates_total);
  }

#endif // VOLUME_DISPLAY_INDICATOR

#endif // VOLUME_DISPLAY_MQH
