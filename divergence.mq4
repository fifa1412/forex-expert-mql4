//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, NoHopz Software Corp."
#property link      "https://www.nohopz.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
//---
   printf("Hello World");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

   input double lots =0.01; // Lots
   input int stop_loss =200; // Stop Loss
   input int take_profit =200; // Take Profit
   input int slippage = 3; // Slippage
   string comment = "Divergence"; //Formula
   string symbol = Symbol(); //Symbol
   input int period = 5; //RSI Period 
   input double fix_min_rsi = 30; //RSI Fix min rsi 
   input double fix_max_rsi = 70; //RSI Fix max rsi 
   int order_ticket = 0;
   
   bool is_init_top = false;
   bool is_start_top = false;
   bool is_end_top = false;
   double close_price_start_top = 0;
   double close_price_end_top = 0;
   double rsi_start_top = 0;
   double rsi_end_top = 0;
   
   bool is_init_bot = false;
   bool is_start_bot = false;
   bool is_end_bot = false;
   double close_price_start_bot = 0;
   double close_price_end_bot = 0;
   double rsi_start_bot = 100;
   double rsi_end_bot = 0;

   // double minstoplevel=(double)MarketInfo(symbol,MODE_STOPLEVEL);
   // calculated SL and TP prices must be normalized
   // double stoploss=NormalizeDouble(Bid-stop_loss*Point,Digits);
   // double takeprofit=NormalizeDouble(Bid+take_profit*Point,Digits);
               
void OnTick()
  {
   double temp_close_m5_s1 = iClose(symbol,PERIOD_M5,1);
   double temp_low_m5_s1 = iLow(symbol,PERIOD_M5,1);
   double temp_high_m5_s1 = iHigh(symbol,PERIOD_M5,1);
//   double temp_low_m1_s1 = iLow(symbol,PERIOD_M1,1);
//   double temp_low_m1_s2 = iLow(symbol,PERIOD_M1,2);
//   double temp_high_m1_s1 = iHigh(symbol,PERIOD_M1,1);
//   double temp_high_m1_s2 = iHigh(symbol,PERIOD_M1,2);
   double temp_rsi_m1_s0 = iRSI(symbol,PERIOD_M1,period,PRICE_CLOSE,0);
   double temp_rsi_m1_s1 = iRSI(symbol,PERIOD_M1,period,PRICE_CLOSE,1);
   double temp_rsi_m5_s0 = iRSI(symbol,PERIOD_M5,period,PRICE_CLOSE,0);
   double temp_rsi_m5_s1 = iRSI(symbol,PERIOD_M5,period,PRICE_CLOSE,1);
   
   double temp_high_m5_s0 = iHigh(symbol,PERIOD_M5,0);
   double temp_low_m5_s0 = iLow(symbol,PERIOD_M5,0);
   double temp_close_m5_s0 = iClose(symbol,PERIOD_M5,0);
   
   string close_order_list = "";
   
   if(is_start_top){
      if(is_end_top){
         if(temp_rsi_m5_s0 > fix_max_rsi){
            if(temp_rsi_m5_s1 > rsi_end_top){
               rsi_end_top = temp_rsi_m5_s1;
               close_price_end_top = temp_high_m5_s1;
            }
         }else{
              // open order 
              printf("Check OP_SELL rsi_start_top : " + (string)rsi_start_top + ", rsi_end_top : " + (string)rsi_end_top +  ", close_price_start_top : " + (string)close_price_start_top + ", close_price_end_top : " + (string)close_price_end_top);
            if(rsi_start_top > rsi_end_top && close_price_end_top > close_price_start_top){
               order_ticket = OrderSend(symbol,OP_SELL,lots,NormalizeDouble(Bid,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
               if(order_ticket > 0){
               printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
               }else{
               printf("Open Order FAILED " + (string)GetLastError());
               }
            }
            is_end_top = false;
            is_start_top = false;
            rsi_start_top = rsi_end_top;
            close_price_start_top = close_price_end_top;
         }
      }else{
         if(temp_rsi_m5_s1 > fix_max_rsi){
           is_end_top = true;
           rsi_end_top = temp_rsi_m5_s1;
           close_price_end_top = temp_high_m5_s1;
         }
      }
   }else{
      //initial
      if(temp_rsi_m5_s1 > fix_max_rsi){
         if(is_init_top){
            if(temp_rsi_m5_s1 > rsi_start_top){
               rsi_start_top  = temp_rsi_m5_s1;
               close_price_start_top = temp_high_m5_s1;
            }
         }else{
            is_init_top = true;
            rsi_start_top  = temp_rsi_m5_s1;
            close_price_start_top = temp_high_m5_s1;
         }
      }else if(is_init_top) {
         // check last rsi
         if(temp_rsi_m5_s1 > rsi_start_top){
            rsi_start_top  = temp_rsi_m5_s1;
            close_price_start_top = temp_high_m5_s1;
         }
         is_start_top = true;
      }
   }
   
   if(is_start_bot){
      if(is_end_bot){
         if(temp_rsi_m5_s0 < fix_min_rsi){
            if(temp_rsi_m5_s0 < rsi_end_bot){
               rsi_end_bot = temp_rsi_m5_s1;
               close_price_end_bot = temp_low_m5_s1;
            }
         }else{
              // open order 
              printf("Check OP_BUY rsi_start_bot : " + (string)rsi_start_bot + ", rsi_end_bot : " + (string)rsi_end_bot +  ", close_price_start_bot : " + (string)close_price_start_bot + ", close_price_end_bot : " + (string)close_price_end_bot);
               if(rsi_end_bot > rsi_start_bot && close_price_start_bot > close_price_end_bot ){
               order_ticket = OrderSend(symbol,OP_BUY,lots,NormalizeDouble(Ask,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
               if(order_ticket > 0){
                  printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
               }else{
                  printf("Open Order FAILED " + (string)GetLastError());
               }
            }
            is_end_bot = false;
            is_start_bot = false;
            rsi_start_bot = rsi_end_bot;
            close_price_start_bot = close_price_end_bot;
         }
      }else{
         if(temp_rsi_m5_s1 < fix_min_rsi){
           is_end_bot = true;
           rsi_end_bot = temp_rsi_m5_s1;
           close_price_end_bot = temp_low_m5_s1;
         }
      }
   }else{
      //initial
      if(temp_rsi_m5_s1 < fix_min_rsi){
         if(is_init_bot){
            if(temp_rsi_m5_s1 < rsi_start_bot){
               rsi_start_bot  = temp_rsi_m5_s1;
               close_price_start_bot = temp_low_m5_s1;
            }
         }else{
            is_init_bot = true;
            rsi_start_bot  = temp_rsi_m5_s1;
            close_price_start_bot = temp_low_m5_s1;
         }
      }else if(is_init_bot) {
         // check last rsi
         if(temp_rsi_m5_s1 < rsi_start_bot){
            rsi_start_bot  = temp_rsi_m5_s1;
            close_price_start_bot = temp_low_m5_s1;
         }
         is_start_bot = true;
      }
   }
   
   //check close order
      for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i, SELECT_BY_POS)==true){
        if(OrderSymbol() == symbol && OrderComment() == comment){
            if(OrderProfit() > (take_profit)*Point){
                close_order_list += (string)OrderTicket()+",";
            }else if(OrderProfit() < -(stop_loss)*Point){
                close_order_list += (string)OrderTicket()+",";
          }
        }
      }
    }
    if(close_order_list != ""){
    string order_list_result[];
    ushort u_sep = StringGetCharacter(",",0);
    int total_order_list = StringSplit(close_order_list,u_sep,order_list_result);
    
    for(int i=0;i<total_order_list-1;i++){
      if(OrderSelect((int)order_list_result[i],SELECT_BY_TICKET)){
        if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
          printf("Close Order SUCCESS (Ticket: "+(string)OrderTicket()+")");
        }else{
          printf("Close Order FAILED " + (string)GetLastError());
        }
      }        
    }
   }
  }
//+------------------------------------------------------------------+
