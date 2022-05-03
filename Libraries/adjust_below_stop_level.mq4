//+------------------------------------------------------------------+
//|                                      adjust_below_stop_level.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
double  AdjustBelowStopLevel(double argAdjustPrice, double argPipPoint, int argAddPips = 0, double argOpenPrice = 0)
    {
        double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
        
        double OpenPrice;
        if  (argOpenPrice == 0) OpenPrice = MarketInfo(Symbol(), MODE_BID);
        else OpenPrice = argOpenPrice;
        
        double LowerStopLevel = OpenPrice - StopLevel;
        
        double AdjustedPrice;
        if (argAdjustPrice >= LowerStopLevel) AdjustedPrice = LowerStopLevel - (argAddPips * argPipPoint);
        else AdjustedPrice = argAdjustPrice;
        
        return AdjustedPrice;
    }
//+------------------------------------------------------------------+
