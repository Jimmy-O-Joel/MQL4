//+------------------------------------------------------------------+
//|                                              break_even_stop.mq4 |
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
void    BreakEven(string argSymbol, int argMagicNumber, int argBreakEven, double argPipPoint)
         {
                //buy order
                for (int i = 0; i < OrdersTotal(); i++)
                    {
                         if (!OrderSelect(i, SELECT_BY_POS))
                            {
                                Print("Order Select Error #", GetLastError(), ": ", ErrorDescription(GetLastError()));
                            }
                        if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY)
                            if  (OrderOpenPrice() + argBreakEven * argPipPoint <= Bid)
                                if (OrderOpenPrice() > OrderStopLoss())
                                    {
                                        bool Mod = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrNONE);    
                                    
                                        if  (!Mod)
                                            {
                                                Print("Order Modify Error # ", GetLastError(), ": ", ErrorDescription(GetLastError()));
                                            }
                                        
                                    }
                                    
                    }
                //Sell order
                for (int i = 0; i < OrdersTotal(); i++)
                    {
                        if (!OrderSelect(i, SELECT_BY_POS))
                            {
                                Print("Order Select Error #", GetLastError(), ": ", ErrorDescription(GetLastError()));
                            }
                        if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL)
                            if  (OrderOpenPrice() - argBreakEven * argPipPoint >= Ask)
                                if  (OrderOpenPrice() < OrderStopLoss() || OrderStopLoss() == 0)  
                                    {  
                                        bool Mod = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrNONE);
                                        
                                        if  (!Mod)
                                            {
                                                Print("Order Modify Error # ", GetLastError(), ": ", ErrorDescription(GetLastError()));
                                            }
                                    }
                        
                    }
                        
         }
//+------------------------------------------------------------------+
