//+------------------------------------------------------------------+
//|                                                 get_slippage.mq4 |
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
int     GetSlippage(string curr, int SlippagePips)
        {
            int CalcDigits = (int)MarketInfo(curr, MODE_DIGITS);
            
            int CalcSlippage = NULL;
            if  (CalcDigits == 2 || CalcDigits == 4) CalcSlippage = SlippagePips;
            else if (CalcDigits == 3 || CalcDigits == 5) CalcSlippage = SlippagePips * 10;
            return CalcSlippage;
        }
//+------------------------------------------------------------------+
