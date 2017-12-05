//
//  FSPlatformCustomViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/12/5.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSPlatformCustomViewController.h"

@interface FSPlatformCustomViewController ()

@property (weak, nonatomic) IBOutlet UITextField *streamAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamKeyTextField;
@property (weak, nonatomic) IBOutlet UIButton    *saveButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic,assign) CGFloat             keyboardHeight;;
@end

@implementation FSPlatformCustomViewController

#pragma mark - Setters/Getters


#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestDataSource];
    [self addNotifacation];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods

- (void)requestDataSource {
    
    
}

#pragma mark – Private methods

- (void)addNotifacation {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
//    if (!_streamKeyTextField.isFirstResponder) {
//        return;
//    }
    CGFloat curkeyBoardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect end = [[[notification userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    float duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 第三方键盘回调三次问题，监听仅执行最后一次
    
    __weak typeof(self) weakself = self;
    if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
        _keyboardHeight = curkeyBoardHeight;
    
    CGFloat offsetY = 0;
    CGFloat maxY = CGRectGetMaxY(_saveButton.frame);
    offsetY = _keyboardHeight - (SCREENHEIGHT - maxY);
    if (offsetY > 0) {
        offsetY += 10;
        [UIView animateWithDuration:duration animations:^{
           weakself.contentView.frame = CGRectMake(0, -offsetY, SCREENWIDTH, SCREENHEIGHT+offsetY);
        } completion:^(BOOL finished) {
            
        }];
    }
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    _keyboardHeight = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = CGRectMake(0, 0, SCREENWIDTH,SCREENHEIGHT);
    } completion:^(BOOL finished) {
    }];
    
}


#pragma mark – Target action methods

- (IBAction)buttonClickAction:(UIButton *)sender {
    
    
}

#pragma mark - IBActions

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate


@end
