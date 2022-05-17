//+------------------------------------------------------------------+
//|                                                 adjust_trail.mq4 |
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
void    TrailingStop(string argSymbol, int argMagicNumber, double argPipPoint, int argTrailingStop)
        {
            //Buy Order Section
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #", GetLastError(), ": ", ErrorDescription(GetLastError()));
                        }
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY)
                        if  (Bid - OrderOpenPrice() > argTrailingStop * argPipPoint)
                            if  (OrderStopLoss() < Bid - argTrailingStop * argPipPoint)
                                {
                                    bool Mod =  OrderModify(OrderTicket(), OrderOpenPrice(), Bid - (argTrailingStop*argPipPoint), OrderTakeProfit(), 0, clrNONE); 
                                    
                                    if  (!Mod)
                                            {
                                                Print("Order Modify Error # ", GetLastError(), ": ", ErrorDescription(GetLastError()));
                                            }
                                }   
                }
                
            //Sell Order Section
            for (int i = OrdersTotal()-1; i >= 0; i--)
                {
                    if (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #", GetLastError(), ": ", ErrorDescription(GetLastError()));
                        }
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL)
                        if  (OrderOpenPrice() - Ask > argTrailingStop * argPipPoint)
                            if  (OrderStopLoss() > Ask + argTrailingStop * argPipPoint || OrderStopLoss() == 0)
                                {
                                    bool Mod =  OrderModify(OrderTicket(), OrderOpenPrice(), Ask + (argTrailingStop*argPipPoint), OrderTakeProfit(), 0, clrNONE); 
                                     
                                    if  (!Mod)
                                            {
                                                Print("Order Modify Error # ", GetLastError(), ": ", ErrorDescription(GetLastError()));
                                            }
                                }
                                 
                }    
        }
//+------------------------------------------------------------------+
