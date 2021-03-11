//+------------------------------------------------------------------+
//|                                            ema200_by_NoHopez.mq4 |
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
double lots = 0.01; // Lots
string symbol = Symbol(); //Symbol
int timeframe = PERIOD_H1;
string comment = "EMA200";
int slippage = 3; // Slippage
int shift = 0; // Shift
int order_ticket = 0;

// Config ADX
int adx_period = 14;
int adx_applied_price = PRICE_CLOSE;

// Config MA
int ma_shift = 0; // MA shift
int ma_method = MODE_EMA; // averaging method
int ma_applied_price= PRICE_WEIGHTED; // applied price

// Config Stoch
int k_period = 5; // K line period
int d_period = 3; // D line period
int slowing = 3; // slowing
int method = MODE_SMA; // Simple averaging
int price_field = 0; // price (0 -> Low/High or 1 -> Close/Close)

bool is_init = false;
bool is_above = false;
bool is_under = false;
bool is_ordered = false;
int temp_bar;
int bar;

double adx_main_s0;
double adx_plus_s0;
double adx_minus_s0;
double adx_main_s1;
double adx_plus_s1;
double adx_minus_s1;

double stoch_main_s0;
double stoch_signal_s0;

double ema200_s0;
double ema200_s1 = iMA(symbol,timeframe,200,ma_shift,ma_method,ma_applied_price,shift+1);

double close_price_s1 = iClose(symbol,timeframe,shift+1);
double low_price_s1;
double high_price_s1;
double close_price_s0;
double low_price_s0;
double high_price_s0;
bool is_print = true;
int print_bar;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(close_price_s1 > ema200_s1){
      is_above = true;
   }else{
      is_under = true;
   }
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+



void OnTick()
  {
//---
   bar = Bars;
   
   ema200_s0 = iMA(symbol,timeframe,200,ma_shift,ma_method,ma_applied_price,shift);
   ema200_s1 = iMA(symbol,timeframe,200,ma_shift,ma_method,ma_applied_price,shift+1);
   
   adx_main_s0 = iADX(symbol,timeframe,adx_period,adx_applied_price,MODE_MAIN,shift);
   adx_plus_s0 = iADX(symbol,timeframe,adx_period,adx_applied_price,MODE_PLUSDI,shift);
   adx_minus_s0 = iADX(symbol,timeframe,adx_period,adx_applied_price,MODE_MINUSDI,shift);
   adx_main_s1 = iADX(symbol,timeframe,adx_period,adx_applied_price,MODE_MAIN,shift+1);
   adx_plus_s1 = iADX(symbol,timeframe,adx_period,adx_applied_price,MODE_PLUSDI,shift+1);
   adx_minus_s1 = iADX(symbol,timeframe,adx_period,adx_applied_price,MODE_MINUSDI,shift+1);
   
   stoch_main_s0 = iStochastic(symbol,timeframe,k_period,d_period,slowing,method,price_field,MODE_MAIN,shift);
   stoch_signal_s0 = iStochastic(symbol,timeframe,k_period,d_period,slowing,method,price_field,MODE_SIGNAL,shift);
   
   close_price_s0 = iClose(symbol,timeframe,shift);
   low_price_s0 = iLow(symbol,timeframe,shift);
   high_price_s0 = iHigh(symbol,timeframe,shift);
   close_price_s1 = iClose(symbol,timeframe,shift+1);
   low_price_s1 = iLow(symbol,timeframe,shift+1);
   high_price_s1 = iHigh(symbol,timeframe,shift+1);

   if(!is_ordered){
      if(high_price_s0 > ema200_s0 && low_price_s0 < ema200_s0){
         if(close_price_s0 < ema200_s0 && ema200_s0 - close_price_s0 < 100*Point){
            // Under
            if(adx_minus_s0 > 25 && adx_main_s0 > 15 && adx_plus_s0 < adx_plus_s1 && adx_minus_s0 > adx_plus_s0){
                  //Open order
                  order_ticket = OrderSend(symbol,OP_SELL,lots,NormalizeDouble(Bid,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
                  if(order_ticket > 0){
                     is_ordered = true;    
                     temp_bar = Bars;
                     printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
                  }else{
                     printf("Open Order FAILED " + (string)GetLastError());
                  }
            }else if((adx_minus_s0 > 15 && adx_main_s0 > 15 && adx_plus_s0 < 25) && (stoch_signal_s0 > stoch_main_s0 && 75 < stoch_main_s0 && stoch_main_s0 < 90 && 75 < stoch_signal_s0 && stoch_signal_s0 < 90)){
                  //Open order
                  order_ticket = OrderSend(symbol,OP_SELL,lots,NormalizeDouble(Bid,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
                  if(order_ticket > 0){
                     is_ordered = true;
                     temp_bar = Bars;
                     printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
                  }else{
                     printf("Open Order FAILED " + (string)GetLastError());
                  }       
            } 
         }else if(close_price_s0 > ema200_s0 && close_price_s0 - ema200_s0 < 100*Point){
            // Above
            if((adx_plus_s0 > 25 && adx_main_s0 > 15 && adx_minus_s0 < adx_minus_s1 && adx_plus_s0 > adx_minus_s0)){
            printf("stoch_main_s0 : " + (string)stoch_main_s0 + " stoch_signal_s0: " + (string)stoch_signal_s0);
               printf("adx_minus_s0 : " + (string)adx_minus_s0 + " adx_main_s0: " + (string)adx_main_s0 + " adx_plus_s0 : " + (string)adx_plus_s0 );
                  //Open order
                  order_ticket = OrderSend(symbol,OP_BUY,lots,NormalizeDouble(Ask,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
                  if(order_ticket > 0){
                     is_ordered = true;
                     temp_bar = Bars;
                     printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
                  }else{
                     printf("Open Order FAILED " + (string)GetLastError());
                  }
            }else if((adx_plus_s0 > 15 && adx_main_s0 > 15 && adx_minus_s0 < 25)&& (stoch_signal_s0 < stoch_main_s0 && 10 < stoch_main_s0 && stoch_main_s0 < 25 && 10 < stoch_signal_s0 && stoch_signal_s0 < 25)){
                  printf("stoch_main_s0 : " + (string)stoch_main_s0 + " stoch_signal_s0: " + (string)stoch_signal_s0);
               printf("adx_minus_s0 : " + (string)adx_minus_s0 + " adx_main_s0: " + (string)adx_main_s0 + " adx_plus_s0 : " + (string)adx_plus_s0 );
                  //Open order
                  order_ticket = OrderSend(symbol,OP_BUY,lots,NormalizeDouble(Ask,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
                  if(order_ticket > 0){
                     is_ordered = true;
                     temp_bar = Bars;
                     printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
                  }else{
                     printf("Open Order FAILED " + (string)GetLastError());
                  }
            }
         }
      }
   }else{
   // Check for close order
      if((bar - temp_bar) > 0 ){
            if(OrderSelect(0, SELECT_BY_POS)==true){
               if ((OrderType() == OP_BUY && close_price_s0 < ema200_s0)){
                  if(is_init){
                     if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
                        printf("Close Order SUCCESS (Ticket: "+(string)OrderTicket()+")");
                        is_ordered = false;
                        is_init = false;
                     }else{
                        printf("Close Order FAILED " + (string)GetLastError());
                     }          
                  }else if(!((adx_plus_s1 > 15 && adx_main_s1 > 15 && adx_plus_s1 > adx_minus_s1) && (low_price_s1 < ema200_s1 && high_price_s1 > ema200_s1))){
                     is_init = true;
                  }
                          
               }else if(OrderType() == OP_SELL && close_price_s0 > ema200_s0){
                  if(is_init){
                     if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
                        printf("Close Order SUCCESS (Ticket: "+(string)OrderTicket()+")");
                        is_ordered = false;
                        is_init = false;
                     }else{
                        printf("Close Order FAILED " + (string)GetLastError());
                     }          
                  }else if(!((adx_minus_s0 > 15 && adx_main_s0 > 15 && adx_minus_s0 > adx_plus_s0) && (low_price_s1 < ema200_s1 && high_price_s1 > ema200_s1))){
                     is_init = true;
                  }
               }
            }
      }
   }
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---   
  }
//+------------------------------------------------------------------+