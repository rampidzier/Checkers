//
//  ViewController.m
//  Checkers
//
//  Created by Robert Dohner on 2/2/15.
//  Copyright (c) 2015 Robert Dohner. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    gameBoard = [[CheckerBoard alloc] initWithFrame:(CGRectMake(([UIScreen mainScreen].bounds.size.width / 2) - 150, ([UIScreen mainScreen].bounds.size.height / 2) - 150, 300, 300))];
    gameBoard.delegate = self;
    
    [self.view addSubview:gameBoard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayMessage:(NSString *)message
{
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(gameBoard.frame.origin.x, gameBoard.frame.origin.y + 250, 150, 100)];
    messageLabel.text = message;
    [self.view addSubview:messageLabel];
}

@end
