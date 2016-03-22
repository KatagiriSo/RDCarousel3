//
//  RDCarousel.m
//  RDCarousel3
//
//  Created by 片桐奏羽 on 2016/03/17.
//  Copyright © 2016年 SoKatagiri.
//  This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

#import "RDCarousel.h"

CGFloat space = 5.0f;

@protocol InfiniteScrollViewDelegate <NSObject>
- (void)scrollView:(UIScrollView *)scrollView currentIndex:(NSInteger)index;
@end

// 無限スクロールは以下を参考にした。 WWDC2011 Advanced ScrollView Techniques
@interface InfiniteScrollView : UIScrollView;
@property (nonatomic, strong) NSMutableArray *visibleViews;
@property (nonatomic, weak) NSArray *contents;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic,weak) id <InfiniteScrollViewDelegate> infDelegate;
@end

@interface RDCarousel() <InfiniteScrollViewDelegate>
@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) InfiniteScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@end


@implementation RDCarousel

- (InfiniteScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[InfiniteScrollView alloc] initWithFrame:self.bounds];
    }
    return _scrollView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

#pragma mark -

- (void)updateContents:(NSArray *)contents dummyNumber:(NSInteger)dummy
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contents = contents;
            self.scrollView.contents = contents;
            self.scrollView.infDelegate = self;
            self.pageControl.numberOfPages = [self.contents count] - dummy;
            
            if ([self.contents count] == 0) return;
            
            NSInteger count = [self.contents count];
            UIView *sampleView = self.contents[0];
            
            // UIScrollView ContentzSize
            CGFloat width = count * CGRectGetWidth(sampleView.frame) + space * count -1 + 5000;
            CGFloat height = CGRectGetHeight(sampleView.frame);
            self.scrollView.contentSize = CGSizeMake(width, height);
            if (!self.scrollView.superview) {
                [self addSubview:self.scrollView];
            }
            self.scrollView.contentView = self.contentView;
            
            self.contentView.frame =  CGRectMake(0, 0, width, height);
            if (!self.contentView.superview) {
                [self.scrollView addSubview:self.contentView];
            }
            
            self.scrollView.showsHorizontalScrollIndicator = NO;
            self.scrollView.clipsToBounds = YES;
            self.contentView.clipsToBounds = YES;
            
        });
    });
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)scrollView:(UIScrollView *)scrollView currentIndex:(NSInteger)index
{
    NSLog(@"currenIndex = %ld", index);
    
    self.pageControl.currentPage = index % self.pageControl.numberOfPages;
}

@end



@implementation InfiniteScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
}

- (NSMutableArray *)visibleViews
{
    if (!_visibleViews) {
        _visibleViews = [[NSMutableArray alloc] init];
    }
    
    return _visibleViews;
}

- (void)recenterIfNecessary
{
    CGPoint currentOffset = self.contentOffset;
    CGFloat width = self.contentSize.width;
    // 中央
    CGFloat x = width / 2;
    
    // Contentが丁度中央にいるときのScrollViewの左端
    CGFloat centerOffsetX = x - [self bounds].size.width/2;
    
    // 中央にいるときとのズレ
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > width/4) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        // todo
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self recenterIfNecessary];
    
    CGRect visibleBounds = [self bounds];
    CGFloat minX = CGRectGetMinX(visibleBounds);
    CGFloat maxX = CGRectGetMaxX(visibleBounds);
    
    [self tileBuildingsFromMinX:minX toMaxX:maxX];
}


- (void)tileBuildingsFromMinX:(CGFloat)minX toMaxX:(CGFloat)maxX
{

    // 右側に飛び出しているViewを削除
    {
        if (self.visibleViews.count > 0) {
            UIView *last = [self.visibleViews lastObject];
            while ([last frame].origin.x > maxX && last) {
                [last removeFromSuperview];
                [self.visibleViews removeLastObject];
                last = [self.visibleViews lastObject];
            }
        }
    }
    
    // 左側に飛び出しているViewを削除
    {
        if (self.visibleViews.count > 0) {
            UIView *first = [self.visibleViews firstObject];
            while (CGRectGetMaxX(first.frame) < minX && first) {
                [first removeFromSuperview];
                [self.visibleViews removeObjectAtIndex:0];
                first = [self.visibleViews firstObject];
            }
        }
    }
    
    // 1個もなければ１個は作っておく。
    if ([self.visibleViews count] == 0) {
        UIView *v = [self placeNewViewOnRight:minX refView:nil];
        [self.contentView addSubview:v];
    }
    
    // 右側に付け加える
    UIView *last = [self.visibleViews lastObject];
    CGFloat rightEdge = CGRectGetMaxX(last.frame);
    while (rightEdge < maxX) {
        last = [self placeNewViewOnRight:rightEdge refView:last];
        rightEdge = CGRectGetMaxX(last.frame);
        [self.contentView addSubview:last];
        
    }
    
    // 左側に付け加える
    UIView *first = [self.visibleViews firstObject];
    CGFloat leftEdge = CGRectGetMinX(first.frame);
    while (leftEdge > minX) {
        first = [self placeNewViewOnLeft:leftEdge refView:first];
        leftEdge = CGRectGetMinX(first.frame);
        [self.contentView addSubview:first];
    }
    

    
    
    if ([self.visibleViews count] == 1) {
        UIView *v = self.visibleViews[0];
        NSInteger index = [self.contents indexOfObject:v];
        [self.infDelegate scrollView:self currentIndex:index];
    } else {
        
        UIView *v = self.visibleViews[0];
        
        CGRect frame = CGRectMake(self.center.x - v.frame.size.width/2, CGRectGetMinY(v.frame), v.frame.size.width, v.frame.size.height);
        
        UIView *center = nil;
        for (UIView *v in self.visibleViews) {
            //v.alpha = 0.5;
            CGRect vf = CGRectMake(v.frame.origin.x - self.contentOffset.x, CGRectGetMinY(v.frame), v.frame.size.width, v.frame.size.height);
            if (CGRectIntersectsRect(vf, frame)) {
                center = v;
                //center.alpha = 1.0;
                break;
            }
        }
        if (center) {
            NSInteger index = [self.contents indexOfObject:center];
            [self.infDelegate scrollView:self currentIndex:index];
        }
    }
    
}


- (UIView *)placeNewViewOnRight:(CGFloat)rightEdge refView:(UIView *)view
{
    
    if ([self.contents count] == 0) {
        return nil;
    }
    
    UIView *placeView = nil;
    if (!view) {
        placeView = self.contents[0];
    } else {
        NSInteger index = [self.contents indexOfObject:view];
        if (index + 1 < [self.contents count]) {
            placeView = self.contents[index+1];
        } else {
            index = index + 1 - [self.contents count];
            placeView = self.contents[index];
        }
    }
    
    [self.visibleViews addObject:placeView];
    
    CGRect frame = [placeView frame];
    frame.origin.x = rightEdge + space;
    placeView.frame = frame;
    
    return placeView;
}

- (UIView *)placeNewViewOnLeft:(CGFloat)leftEdge refView:(UIView *)view
{
    if ([self.contents count] == 0) {
        return nil;
    }
    
    UIView *placeView = nil;
    if (!view) {
        placeView = self.contents[0];
    } else {
        NSInteger index = [self.contents indexOfObject:view];
        if (index - 1 >= 0) {
            placeView = self.contents[index-1];
        } else {
            index = index - 1 + [self.contents count];
            placeView = self.contents[index];
        }
    }
    
    [self.visibleViews addObject:placeView];
    
    CGRect frame = [placeView frame];
    frame.origin.x = leftEdge - frame.size.width - space;
    placeView.frame = frame;
    
    return placeView;
}



@end





