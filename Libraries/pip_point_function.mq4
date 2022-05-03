//+------------------------------------------------------------------+
//|                                           pip_point_function.mq4 |
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
double  pipPoint(const string currSymbol)
        {
                double bid = SymbolInfoDouble(currSymbol, SYMBOL_BID);
                int digits = (int)SymbolInfoInteger(currSymbol, SYMBOL_DIGITS);
                double points = SymbolInfoDouble(currSymbol, SYMBOL_POINT);
                 
                if (StringFind(currSymbol, "XAU") > -1 || StringFind(currSymbol, "xau") > -1 || StringFind(currSymbol, "GOLD") > -1) return points; //Gold
                if (digits <= 1) points = 1; //CFD & Index
                if (digits == 4 || digits == 5) points = 0.0001;
                if ((digits == 2 || digits == 3) && bid > 1000) points = 1;
                if ((digits == 2 || digits == 3) && bid < 1000) points = 0.01;
                
                return points;
        }
//+------------------------------------------------------------------+
