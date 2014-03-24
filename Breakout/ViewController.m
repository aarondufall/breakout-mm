//
//  ViewController.m
//  Breakout
//
//  Created by Aaron Dufall on 22/03/2014.
//  Copyright (c) 2014 Aaron Dufall. All rights reserved.
//

#import "ViewController.h"
#import "PaddleView.h"
#import "BallView.h"
#import "BlockView.h"

@interface ViewController () <UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet PaddleView *paddleView;
@property (weak, nonatomic) IBOutlet BallView *ballView;

@property NSMutableArray *blocks;


@end

@implementation ViewController
{
    UIDynamicAnimator *dynamicAnimator;
    UIPushBehavior    *pushBehavior;
    UICollisionBehavior *collissionBehavior;
    UIDynamicItemBehavior *paddleDynamicBehavior;
    UIDynamicItemBehavior *ballDynamicBehavior;
    int columns;
    int rows;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
	dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    pushBehavior    = [[UIPushBehavior alloc]initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    collissionBehavior = [[UICollisionBehavior alloc]initWithItems:@[self.ballView, self.paddleView]];
    paddleDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[self.paddleView]];
    ballDynamicBehavior   =  [[UIDynamicItemBehavior alloc]initWithItems:@[self.ballView]];
    

    
    
    columns = 6;
    rows    = 4;
    _blocks = [[NSMutableArray alloc]initWithCapacity:columns * rows];
    
    for (int i = 0; i < columns * rows; i++) {
        BlockView *block = [[BlockView alloc]init];
        [_blocks addObject:block];
    }
    

    
    [self setupLevel];
    
    ballDynamicBehavior.allowsRotation = NO;
    ballDynamicBehavior.elasticity = 1.0;
    ballDynamicBehavior.friction = 0.0;
    ballDynamicBehavior.resistance = 0.0;
    [dynamicAnimator addBehavior:ballDynamicBehavior];
    
    
    paddleDynamicBehavior.allowsRotation = NO;
    paddleDynamicBehavior.density = 1000;
    [dynamicAnimator addBehavior:paddleDynamicBehavior];
    
    collissionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    collissionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collissionBehavior.collisionDelegate = self;
    [dynamicAnimator addBehavior:collissionBehavior];
    
    pushBehavior.pushDirection = CGVectorMake(0.5, 1.0);
    pushBehavior.active = YES;
    pushBehavior.magnitude = 0.1;
    [dynamicAnimator addBehavior:pushBehavior];

}


-(void)setupLevel
{
    self.ballView.center = CGPointMake(self.view.center.x, self.view.center.y);
    [dynamicAnimator updateItemUsingCurrentState:self.ballView];
    
    int offset  = 20;
    CGFloat width = (self.view.frame.size.width - (offset * 2)) / columns;
    NSMutableArray *blockFrames = [[NSMutableArray alloc]initWithCapacity:columns * rows];
    for (int r = 0; r < rows; r++) {
        for (int i = 0; i < columns; i++) {
            CGRect blockRect = CGRectMake(offset + (width * i) , offset + (18 * r), width - 3, 15);
            [blockFrames addObject:[NSValue valueWithCGRect:blockRect]];
        }
    }
    
    
    for (int i = 0; i < [_blocks count]; i++){
        BlockView *block = [_blocks objectAtIndex:i];
        [self.view addSubview:block];
        block.frame = [[blockFrames objectAtIndex:i]CGRectValue];
        block.alpha = 1;
        if (i % rows == 0) {
            block.backgroundColor = [UIColor greenColor];
        } else {
            block.backgroundColor = [UIColor orangeColor];
        }
        UIDynamicItemBehavior *blockDynamicBehavior  =  [[UIDynamicItemBehavior alloc]initWithItems:@[block]];
        blockDynamicBehavior.allowsRotation = NO;
        blockDynamicBehavior.density = 1000;
        [dynamicAnimator addBehavior:blockDynamicBehavior];
        [collissionBehavior addItem:block];
        [dynamicAnimator updateItemUsingCurrentState:block];
    }

    [_blocks removeAllObjects];
    
}

- (BOOL)shouldStartAgain
{
    return [_blocks count] >= columns * rows;
}


- (IBAction)dragPaddle:(UIPanGestureRecognizer *)sender {
    self.paddleView.center = CGPointMake([sender locationInView:self.view].x , self.paddleView.center.y);
    [dynamicAnimator updateItemUsingCurrentState:self.paddleView];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (p.y + self.ballView.frame.size.height >= self.view.frame.size.height) {
        self.ballView.center = CGPointMake(self.view.center.x, self.view.center.y);
        [dynamicAnimator updateItemUsingCurrentState:self.ballView];
    }
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2
{
    BlockView *block;
    if ([item1 isKindOfClass:[BlockView class]]) {
        block = (BlockView *)item1;
    }
    if ([item2 isKindOfClass:[BlockView class]]) {
        block = (BlockView *)item2;
    }
    
    if (block) {
        if (block.backgroundColor == [UIColor greenColor])
        {
            block.backgroundColor = [UIColor orangeColor];
        } else {
            [_blocks addObject:block];
            [collissionBehavior removeItem:block];
            [UIView animateWithDuration:0.3 animations:^{
                block.alpha = 0;
                block.backgroundColor = [UIColor purpleColor];
            } completion:^(BOOL finished) {
                [block removeFromSuperview];
            }];
        }
        
        
        if ([self shouldStartAgain]) {
            [self setupLevel];
        }
    }

    
    
}


@end
