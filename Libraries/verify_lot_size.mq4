//+------------------------------------------------------------------+
//|                                              verify_lot_size.mq4 |
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
double  VerifyLotSize(double argLotSize)
    {
        if  (argLotSize < MarketInfo(Symbol(), MODE_MINLOT))
            {
                argLotSize = MarketInfo(Symbol(), MODE_MINLOT);
            }
        else if (argLotSize > MarketInfo(Symbol(), MODE_MAXLOT))
            {
                argLotSize = MarketInfo(Symbol(), MODE_MAXLOT);
            }
            
        if  (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) {
            argLotSize = NormalizeDouble(argLotSize,1);
        }
        else argLotSize = NormalizeDouble(argLotSize,2);
        
        return argLotSize;
    }
//+------------------------------------------------------------------+
