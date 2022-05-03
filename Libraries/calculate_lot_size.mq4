//+------------------------------------------------------------------+
//|                                           calculate_lot_size.mq4 |
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
double  CalcLotSize(bool argDynamicLotSize, double argEquityPercent, double argStopLoss, double argFixedLotSize=0)
    {
        double LotSize;
        if  (argDynamicLotSize == true && argStopLoss > 0)
            {
                double RiskAmount = AccountEquity() * (argEquityPercent / 100);
                double TickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
                
                if  (Point == 0.001 || Point == 0.00001) TickValue *= 10;
                
                LotSize = (RiskAmount / argStopLoss) / TickValue;
            }
         else  LotSize = argFixedLotSize;
         
         return LotSize;
    }
//+------------------------------------------------------------------+
