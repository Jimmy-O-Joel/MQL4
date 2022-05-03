//+------------------------------------------------------------------+
//|                                      verify_lower_stop_level.mq4 |
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
bool    VerifyLowerStopLevel(double argVerifyPrice, double argOpenPrice = 0)
    {
        double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
        
        double OpenPrice;
        if (argOpenPrice == 0) OpenPrice = MarketInfo(Symbol(), MODE_BID);
        else OpenPrice = argOpenPrice;
        
        double LowerStopLevel = OpenPrice - StopLevel;
        
        bool StopVerify;
        if (argVerifyPrice < LowerStopLevel) StopVerify = true;
        else StopVerify = false;
        
        return StopVerify;
    }
//+------------------------------------------------------------------+
