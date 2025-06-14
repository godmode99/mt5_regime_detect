#ifndef STDDEV_DISPLAY_MQH
#define STDDEV_DISPLAY_MQH

#include "atr_tools.mqh"

#ifdef STDDEV_DISPLAY_INDICATOR

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_label1  "StdDev"
#property indicator_label2  "HighTh"
#property indicator_label3  "LowTh"

input int    InpStdPeriod      = 20;     // period for StdDev
input double InpHighThreshold  = 0.0;    // high threshold
input double InpLowThreshold   = 0.0;    // low threshold
input color  InpStdColor       = clrDodgerBlue; // StdDev line color
input color  InpHighColor      = clrRed;        // high threshold color
input color  InpLowColor       = clrGreen;      // low threshold color
input bool   InpEnableAlerts   = true;   // alert on threshold cross

double g_std_buffer[];
double g_high_buffer[];
double g_low_buffer[];
int    g_std_handle = INVALID_HANDLE;

int OnInit()
  {
   SetIndexBuffer(0,g_std_buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,"StdDev");
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpStdColor);

   SetIndexBuffer(1,g_high_buffer,INDICATOR_DATA);
   PlotIndexSetString(1,PLOT_LABEL,"HighTh");
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,InpHighColor);

   SetIndexBuffer(2,g_low_buffer,INDICATOR_DATA);
   PlotIndexSetString(2,PLOT_LABEL,"LowTh");
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,InpLowColor);

   g_std_handle=iStdDev(_Symbol,_Period,InpStdPeriod,0,MODE_SMA,PRICE_CLOSE);
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
   int start = prev_calculated==0 ? 0 : prev_calculated-1;
   int copied = CopyBuffer(g_std_handle,0,start,rates_total-start,g_std_buffer);
   if(copied<=0)
      return(0);

   for(int i=start;i<rates_total;i++)
     {
      g_high_buffer[i] = InpHighThreshold;
      g_low_buffer[i]  = InpLowThreshold;

      if(InpEnableAlerts && i>0)
        {
         if(InpHighThreshold>0 && g_std_buffer[i]>InpHighThreshold && g_std_buffer[i-1]<=InpHighThreshold)
            Alert(StringFormat("StdDev crossed above %.5f at %s",InpHighThreshold,TimeToString(time[i])));
         if(InpLowThreshold>0 && g_std_buffer[i]<InpLowThreshold && g_std_buffer[i-1]>=InpLowThreshold)
            Alert(StringFormat("StdDev crossed below %.5f at %s",InpLowThreshold,TimeToString(time[i])));
        }
     }
   return(rates_total);
  }

#endif // STDDEV_DISPLAY_INDICATOR

#endif // STDDEV_DISPLAY_MQH
