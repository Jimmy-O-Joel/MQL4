//+------------------------------------------------------------------+
//|                                          check_if_open_order.mq4 |
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
bool    CheckIfOpenOrders(int argMagicNumber)
        {
           int openOrders = OrdersTotal();
           
           for(int i = 0; i < openOrders; i++)
           {
              if(OrderSelect(i,SELECT_BY_POS)==true)
              {
                 if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == Symbol()) 
                 {
                    return true;
                 }  
              }
           }
           return false;
        }
//+------------------------------------------------------------------+
