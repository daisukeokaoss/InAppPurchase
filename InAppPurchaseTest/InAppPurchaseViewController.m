//
//  InAppPurchaseViewController.m
//  InAppPurchaseTest
//
//  Created by おかやん on 2014/08/14.
//  Copyright (c) 2014年 ナノソフトウェア. All rights reserved.
//

#import "InAppPurchaseViewController.h"

@interface InAppPurchaseViewController ()

- (IBAction)PurchaseButtonClick:(UIButton *)sender;

@end

@implementation InAppPurchaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)_checkInAppPurchase
{
    if(![SKPaymentQueue canMakePayments]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"アプリ内課金が制限されています" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return NO;
    }
    return YES;
}

-(void)_startInAppPurchase
{
    NSSet *set = [NSSet setWithObjects:@"biz.nanosoftware.application.productid",nil];
    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    productRequest.delegate = self;
    [productRequest start];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if([response.invalidProductIdentifiers count] > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"アイテムIDが不正です" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    for(SKProduct *product in [SKPayment paymentWithProduct:product]){
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    UIAlertView *alert;
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"購入処理中");
                //インジケーターなど回して頑張っている感を出す
                break;
            case SKPaymentTransactionStatePurchased:
                alert = [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"購入成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                //アイテム購入した処理(アップグレード版の機能制限解除処理等
                //購入の持続的な記録
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"購入失敗" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                break;
            case SKPaymentTransactionStateRestored:
                alert = [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"リストア成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                break;
                
            default:
                [queue finishTransaction:transaction];
                
        }
    }
}

- (IBAction)PurchaseButtonClick:(UIButton *)sender {
    if([self _checkInAppPurchase]){
        [self _startInAppPurchase];
        
    }
}
@end
