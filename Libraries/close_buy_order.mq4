//+------------------------------------------------------------------+
//|                                              close_buy_order.mq4 |
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
bool    CloseBuyOrder(string argSymbol, int argCloseTicket, int argSlippage)
        {
            if  (!OrderSelect(argCloseTicket,SELECT_BY_TICKET))
                {
                    Print("Order Select error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                }
            
            bool Closed = NULL;
            
            if  (OrderCloseTime() == 0)
                {
                    double CloseLots = OrderLots();
                    
                    while(IsTradeContextBusy()) Sleep(10);
                    
                    double ClosePrice = MarketInfo(argSymbol,MODE_BID);
                    
                    Closed = OrderClose(argCloseTicket,CloseLots,ClosePrice, argSlippage,clrGreen);
                    
                    if(Closed == false)
                        {
                        
                            Print("Close Buy Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                            Print("Ticket: " + IntegerToString(argCloseTicket) + " Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)));
                            
                        }
                }
            return(Closed);
        }

//+------------------------------------------------------------------+
