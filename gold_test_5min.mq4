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
int timeframe = PERIOD_M5;
string comment = "Gold_M5";
int slippage = 3; // Slippage
int shift = 1; // Shift
double stop_loss = (200*lots)*100; // Stop Loss
int order_ticket = 0;

// Config MA
int ma_shift = 0; // MA shift
int ma_method = MODE_SMA; // averaging method
int ma_applied_price= PRICE_WEIGHTED; // applied price
int ma_applied_price_close = PRICE_CLOSE;
int ma_applied_price_open = PRICE_OPEN;

// Config Stoch
int k_period = 5; // K line period
int d_period = 3; // D line period
int slowing = 3; // slowing
int method = MODE_SMA; // Simple averaging
int price_field = 0; // price (0 -> Low/High or 1 -> Close/Close)

// Config MACD
int fast_ema_period = 12;
int slow_ema_period = 26;
int signal_period = 1;
int macd_applied_price = PRICE_CLOSE;

bool is_intersection = false;
bool is_up = false;
bool is_down = false;
bool is_ordered = false;

double stoch_main_s0;
double stoch_main_s1;
double stoch_main_s2;

double macd_s0;
double macd_s1;

double ema5_close_sm1;
double ema5_open_sm1;
double ema5_close_s0 = iMA(symbol,timeframe,5,ma_shift,ma_method,ma_applied_price_close,shift);
double ema5_open_s0 = iMA(symbol,timeframe,5,ma_shift,ma_method,ma_applied_price_open,shift);

int temp_bar;
int bar;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    if(ema5_close_s0 > ema5_open_s0){
        is_up = true;
    }else{
        is_down = true;
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
    stoch_main_s0 = iStochastic(symbol,timeframe,k_period,d_period,slowing,method,price_field,MODE_MAIN,shift);
    stoch_main_s1 = iStochastic(symbol,timeframe,k_period,d_period,slowing,method,price_field,MODE_MAIN,shift+1);
    stoch_main_s2 = iStochastic(symbol,timeframe,k_period,d_period,slowing,method,price_field,MODE_MAIN,shift+2);

    ema5_close_sm1 = iMA(symbol,timeframe,5,ma_shift,ma_method,ma_applied_price_close,shift-1);
    ema5_open_sm1 = iMA(symbol,timeframe,5,ma_shift,ma_method,ma_applied_price_open,shift-1);
    ema5_close_s0 = iMA(symbol,timeframe,5,ma_shift,ma_method,ma_applied_price_close,shift);
    ema5_open_s0 = iMA(symbol,timeframe,5,ma_shift,ma_method,ma_applied_price_open,shift);
  
    macd_s0 = iMACD(symbol,timeframe,fast_ema_period,slow_ema_period,signal_period,macd_applied_price,MODE_MAIN,shift);
    macd_s1 = iMACD(symbol,timeframe,fast_ema_period,slow_ema_period,signal_period,macd_applied_price,MODE_MAIN,shift+1);

    if(!is_ordered){
        if(is_up){
            if(is_intersection){
                if((stoch_main_s1 < 20) 
                && (stoch_main_s0 > stoch_main_s1) 
                && (macd_s0 > macd_s1)
                && (ema5_close_s0 > ema5_open_s0)){
                    order_ticket = OrderSend(symbol,OP_BUY,lots,NormalizeDouble(Ask,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
                    if(order_ticket > 0){
                        temp_bar = Bars;
                        is_ordered = true;
                        printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
                    }else{
                        printf("Open Order FAILED " + (string)GetLastError());
                    }
                }
                is_intersection = false;
            }else{
                if(ema5_close_s0 < ema5_open_s0){
                    is_intersection = true;
                    is_up = false;
                    is_down = true;
                }
            }
        }else if(is_down){
            if(is_intersection){
                if((stoch_main_s1 > 80) 
                    && (stoch_main_s0 < stoch_main_s1) 
                    && (macd_s0 < macd_s1)
                    && (ema5_close_s0 > ema5_open_s0)){
                        order_ticket = OrderSend(symbol,OP_SELL,lots,NormalizeDouble(Bid,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
                        if(order_ticket > 0){
                            temp_bar = Bars;
                            is_ordered = true;
                            printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
                        }else{
                            printf("Open Order FAILED " + (string)GetLastError());
                        }  
                }
                is_intersection = false;
            }else{
                if(ema5_close_s0 > ema5_open_s0){
                    is_intersection = true;
                    is_down = false;
                    is_up = true;
                }
            }
        }
    }else {
      if((bar - temp_bar) > 0){
        if(OrderSelect(0, SELECT_BY_POS)==true){
            if(OrderProfit() < -stop_loss*Point){
               if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
                    printf("Close Order SUCCESS (Ticket: "+(string)OrderTicket()+")");
                    is_ordered = false;
                    if(ema5_close_s0 > ema5_open_s0){
                        is_up = true;
                     }else{
                        is_down = true;
                     }
                }else{
                    printf("Close Order FAILED " + (string)GetLastError());
                }
            }else if ((OrderType() == OP_BUY && ema5_close_sm1 < ema5_open_sm1)){
            printf("ema5_close_s0 : " + (string)ema5_close_s0 + " ema5_open_s0: " + (string)ema5_open_s0);
                if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
                    printf("Close Order SUCCESS (Ticket: "+(string)OrderTicket()+")");
                    is_ordered = false;
                    is_intersection = true;
                    is_up = false;
                    is_down = true;
                }else{
                    printf("Close Order FAILED " + (string)GetLastError());
                }                                
            }else if(OrderType() == OP_SELL && ema5_close_sm1 > ema5_open_sm1){
            printf("ema5_close_s0 : " + (string)ema5_close_s0 + " ema5_open_s0: " + (string)ema5_open_s0);
                if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
                    printf("Close Order SUCCESS (Ticket: "+(string)OrderTicket()+")");
                    is_ordered = false;
                    is_intersection = true;
                    is_down = false;
                    is_up = true;
                }else{
                    printf("Close Order FAILED " + (string)GetLastError());
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