//
//  ViewController.m
//  RDCarousel3
//
//  Created by 片桐奏羽 on 2016/03/17.
//  Copyright © 2016年 SoKatagiri.
//  This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

#import "ViewController.h"
#import "RDCarousel.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet RDCarousel *carousel;
@end

@implementation ViewController


- (UIView *)makeView
{
    static int i=0;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    v.backgroundColor = [UIColor purpleColor];
    UILabel *l = [[UILabel alloc] initWithFrame:v.bounds];
    l.text = [NSString stringWithFormat:@"%d",i];
    i++;
    [v addSubview:l];
    return v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *list = [NSMutableArray array];
    for (int i=0;i<20;i++)
    {
        [list addObject:[self makeView]];
    }
    
    [self.carousel updateContents:list];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
