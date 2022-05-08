//+------------------------------------------------------------------+
//|                                          close_pending_order.mq4 |
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
bool    ClosePendingOrder(string argSymbol, int argCloseTicket)
        {
            if  (!OrderSelect(argCloseTicket, SELECT_BY_TICKET))
                {
                    Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                }
                
            bool Deleted = false;    
            
            if (OrderCloseTime() == 0)
                {
                    while   (IsTradeContextBusy()) Sleep(10);
                    Deleted = OrderDelete(argCloseTicket, clrRed);
                    
                    if  (!Deleted)
                        {
                            Print("Close Pending Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                            Print("Ticket: " + IntegerToString(argCloseTicket) + " Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Ask: " + DoubleToString(MarketInfo(argSymbol, MODE_ASK)));
                        }
                }
            return Deleted;    
        }
//+------------------------------------------------------------------+
