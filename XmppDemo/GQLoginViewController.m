//
//  GQLoginViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQLoginViewController.h"
#import "GQAppDelegate.h"
#import "GQStatic.h"
#import "GQStreamManager.h"

static NSString* LOGINVIEW = @"LoginView";
@interface GQLoginViewController () //<GQLoginDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *serverAddressField;

- (IBAction)login:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
@end

@implementation GQLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GQStreamManager *streamManager = [GQStreamManager manager];
    //streamManager.loginDelegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess) name:STREAM_MANAGER_LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginFail) name:STREAM_MANAGER_LOGIN_FAIL object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connectFail) name:STREAM_MANAGER_CONNECT_FAIL object:nil];}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:STREAM_MANAGER_LOGIN_FAIL object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:STREAM_MANAGER_LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:STREAM_MANAGER_CONNECT_FAIL object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)login:(id)sender {
    //NSString* ret = [NSString stringWithFormat:@"%@@%@", self.nameField.text, HOSTNAME];
    //[[NSUserDefaults standardUserDefaults] setObject:ret forKey:USERID];
    [[NSUserDefaults standardUserDefaults] setObject:self.nameField.text forKey:USERID];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:PASS];
    [[NSUserDefaults standardUserDefaults] setObject:self.serverAddressField.text forKey:SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:@"iPhone" forKey:SOURCE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Saved standardUserDefaults");
    
    //[[GQStatic appDelegate] connect];
    GQStreamManager *streamManager = [GQStreamManager manager];
    //[streamManager connect];
    [streamManager login];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)hideKeyboard:(id)sender {
    [self.nameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.serverAddressField resignFirstResponder];
}

- (void)loginSuccess {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@: didAuthenticate.", LOGINVIEW);
}

- (void)loginFail {
    [GQStatic clearUserDeaults];
    self.passwordField.text = nil;
    UIAlertController *loginAlert = [UIAlertController
                                     alertControllerWithTitle:WARNING message:PASSWORD_ERROR preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction
                               actionWithTitle:OK
                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                               }];
    [loginAlert addAction:okAction];
    [self presentViewController:loginAlert animated:YES completion:nil];
}

- (void)connectFail {
    UIAlertController *loginAlert = [UIAlertController
                                     alertControllerWithTitle:WARNING message:CONNECT_FAILED preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction
                               actionWithTitle:OK
                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [loginAlert addAction:okAction];
    [self presentViewController:loginAlert animated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.serverAddressField resignFirstResponder];
}
@end
