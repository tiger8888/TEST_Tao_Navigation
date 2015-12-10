//
//  ViewController.m
//  TEST_Tao_Navigation
//
//  Created by SuperNova on 15/11/26.
//  Copyright © 2015年 SuperNova. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conWidthCts;
@property (weak, nonatomic) IBOutlet UIView *conview;
@property (weak, nonatomic) IBOutlet UIScrollView *topScrollview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopGapCts;
@property(nonatomic,strong) UIScrollView* bottomScrollView;
@property(nonatomic,assign) UIEdgeInsets originalInset;
@property(nonatomic,assign) BOOL isAnimationing;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAnimationing=NO;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.edgesForExtendedLayout=UIRectEdgeTop;
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    UIBarButtonItem* leftItem=[[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    UIImageView* imgview=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
    imgview.frame=CGRectMake(0, 0, 30, 20);
    imgview.layer.masksToBounds=YES;
    imgview.layer.cornerRadius=10.f;
    imgview.layer.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.8].CGColor;
    
    UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    btn.frame=CGRectMake(0, 0, 30, 20);
    btn.tintColor=[UIColor whiteColor];
    btn.layer.masksToBounds=YES;
    btn.layer.cornerRadius=10.f;
    btn.layer.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.8].CGColor;
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftItem.customView=btn;
    self.navigationItem.leftBarButtonItem=leftItem;
    self.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
    
}

-(void)backAction{
    NSLog(@"backAction");
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithBgColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:0]] forBarMetrics:UIBarMetricsDefault];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    CGSize s=_topScrollview.contentSize;
    CGRect r=CGRectMake(0, s.height, s.width,self.view.frame.size.height-64);
    UINib* nib=[UINib nibWithNibName:@"scrollView" bundle:nil];
    NSArray* viewArr=[nib instantiateWithOwner:nil options:nil];
    UIScrollView* bottomView=viewArr.lastObject;
    bottomView.frame=r;
    bottomView.delegate=self;
    self.bottomScrollView=bottomView;
    [_topScrollview addSubview:bottomView];
    self.originalInset=_topScrollview.contentInset;
    [self addPageView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(UIImage *)imageWithBgColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([scrollView isEqual:_topScrollview]){
        CGFloat hgap=275-self.navigationController.navigationBar.frame.size.height-20;
        CGFloat dis=scrollView.contentOffset.y;
        if(dis<=hgap&&dis>=0){
            _contentTopGapCts.constant=dis;
            [self.navigationController.navigationBar setBackgroundImage:[self imageWithBgColor:[[UIColor lightGrayColor]colorWithAlphaComponent:dis/hgap] ] forBarMetrics:UIBarMetricsDefault];
            self.navigationItem.leftBarButtonItem.customView.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.8*(1-dis/hgap)];
        }
        
        if(dis<0){
            _contentTopGapCts.constant=0;
        }
        
        if(dis>=hgap){
            self.navigationController.navigationBar.translucent=NO;
        }
        else{
            self.navigationController.navigationBar.translucent=YES;
        }
        
        CGFloat toNextPageOffset=70;
        if(dis>=_topScrollview.contentSize.height-self.view.frame.size.height+toNextPageOffset&&_topScrollview.isDragging==NO){
            if(!_isAnimationing){
                CGPoint p=_topScrollview.contentOffset;
                p.y=_topScrollview.contentSize.height-64;
                UIEdgeInsets e=_topScrollview.contentInset;
                e.bottom=self.view.frame.size.height-64;
                self.isAnimationing=YES;
                [UIView animateWithDuration:0.5 animations:^{
                    _topScrollview.contentOffset=p;
                    _topScrollview.contentInset=e;
                } completion:^(BOOL b){
                    _topScrollview.panGestureRecognizer.enabled=NO;
                    self.isAnimationing=NO;
                }];
            }
        }
    }
    
    if([scrollView isEqual:_bottomScrollView]){
        CGFloat dis=_bottomScrollView.contentOffset.y;
        if(dis<-50&&_bottomScrollView.isDragging==NO){
            if(!_isAnimationing){
                CGPoint p=_topScrollview.contentOffset;
                p.y=_topScrollview.contentSize.height-self.view.frame.size.height;
                self.isAnimationing=YES;
                [UIView animateWithDuration:0.5 animations:^{
                    _topScrollview.contentOffset=p;
                    _topScrollview.contentInset=_originalInset;
                } completion:^(BOOL b){
                    self.isAnimationing=NO;
                    _topScrollview.panGestureRecognizer.enabled=YES;
                }];
            }
        }
    }
}

-(void)addPageView{
    UIView* preView=nil;
    for(int i=0;i<4;i++){
        UIView* v=[self makePicView:[NSString stringWithFormat:@"dog%d.jpg",i]];
        [_conview addSubview:v];
        NSDictionary* metric=@{@"w":@(self.view.frame.size.width)};
        if(preView==nil){
            NSDictionary* viewdic=@{
                                    @"v":v
                                    };
            [_conview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v(==w)]" options:0 metrics:metric views:viewdic]];
            [_conview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:viewdic]];
        }
        else{
            NSDictionary* viewdic=@{
                                    @"v":v,
                                    @"p":preView
                                    };
            [_conview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[p][v(==w)]" options:0 metrics:metric views:viewdic]];
            [_conview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:viewdic]];
        }
        preView=v;
    }
    _conWidthCts.constant=3*self.view.frame.size.width;
}

-(UIView*)makePicView:(NSString*)picName{
    UIView* view=[[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints=NO;
    UIImageView* v=[[UIImageView alloc] initWithImage:[UIImage imageNamed:picName]];
    v.translatesAutoresizingMaskIntoConstraints=NO;
    [view addSubview:v];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.view.frame.size.width]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:275]];
    return view;
}
@end
