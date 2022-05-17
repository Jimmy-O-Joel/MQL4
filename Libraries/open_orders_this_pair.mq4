//+------------------------------------------------------------------+
//|                                        open_orders_this_pair.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
int     OpenOrdersThisPair(string argSymbol)
        {
            int Total = 0;
            
            for (int i = OrdersTotal(); i > 0; i--)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error # ",GetLastError(),": ", ErrorDescription(GetLastError()));
                        }
                    if  (OrderSymbol() == argSymbol)
                        {
                            Total++;
                        }    
                }
            return Total;    
        }
//+------------------------------------------------------------------+
