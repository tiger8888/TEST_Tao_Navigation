//
//  MyScrollView.m
//  TEST_Tao_Navigation
//
//  Created by SuperNova on 15/12/10.
//  Copyright © 2015年 SuperNova. All rights reserved.
//

#import "MyScrollView.h"
@interface MyScrollView()<UIScrollViewDelegate>
{
CGFloat lastContentOffset;
}
@property(nonatomic,strong) UIPageControl* pageControl;
@end

@implementation MyScrollView

-(void)layoutSubviews{
    [super layoutSubviews];
    if(_pageControl==nil){
        self.delegate=self;
        _pageControl=[[UIPageControl alloc] init];
        _pageControl.numberOfPages=4;
        [self.superview addSubview:_pageControl];
        _pageControl.frame=CGRectMake((self.frame.size.width-150)/2.0f, self.frame.size.height-30, 150, 30);
        [self bringSubviewToFront:_pageControl];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.frame.size.width;
    int page=0;
    //根据滚动方向来设置取值的方式不同
    if(lastContentOffset>scrollView.contentOffset.x){
        page =(int)(ceil(scrollView.contentOffset.x / pageWidth));
    }
    else if(lastContentOffset<scrollView.contentOffset.x){
        page =(int)(floor(scrollView.contentOffset.x / pageWidth));
    }
    lastContentOffset=scrollView.contentOffset.x;
    _pageControl.currentPage=page;
}
@end
