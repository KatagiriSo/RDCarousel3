//
//  RDCarousel.h
//  RDCarousel3
//
//  Created by 片桐奏羽 on 2016/03/17.
//  Copyright © 2016年 SoKatagiri.
//  This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

// Version 0.1

#import <UIKit/UIKit.h>

@protocol CopyProtocol <NSObject>
- (id)copy;
@end

@interface RDCarousel : UIView
@property (nonatomic, readonly) NSArray *contents;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

- (void)updateContents:(NSArray<UIView<CopyProtocol>*> *)contents;
@end
