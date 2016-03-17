//
//  RDCarousel.h
//  RDCarousel3
//
//  Created by 片桐奏羽 on 2016/03/17.
//  Copyright © 2016年 SoKatagiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDCarousel : UIView
@property (nonatomic, readonly) NSArray *contents;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

- (void)updateContents:(NSArray *)contents;

@end
