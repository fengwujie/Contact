//
//  ViewController.m
//  Contact
//
//  Created by allen on 16/5/15.
//  Copyright © 2016年 allen. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ViewController ()
//历史数量值
@property (weak, nonatomic) IBOutlet UILabel *historyCount;
//批次导入数量值
@property (weak, nonatomic) IBOutlet UITextField *importCount;
//姓名默认为手机号
@property (weak, nonatomic) IBOutlet UIButton *check1;
//姓名随机生成
@property (weak, nonatomic) IBOutlet UIButton *check2;
@property (weak, nonatomic) IBOutlet UILabel *errorMsg;
/**
 *  上限数量
 */
@property (weak, nonatomic) IBOutlet UITextField *maxCount;
/**
 *  默认导入文件名
 */
@property (weak, nonatomic) IBOutlet UITextField *defaultTxtName;
/**
 *  通讯录来源文件名
 */
@property (weak, nonatomic) IBOutlet UITextField *contactTxtName;

@property (assign, nonatomic) NSInteger iHistoryCount;
@property (strong,nonatomic) NSArray *arrayPhone;
@property (strong,nonatomic) NSArray *arrayContact;
//清空通讯录
- (IBAction)btnClearContact:(id)sender;
//添加通讯录
- (IBAction)btnAddContact:(id)sender;
//清空历史
- (IBAction)btnClearHistory:(id)sender;
//姓名默认为手机号
- (IBAction)btnCheck1:(id)sender;
//姓名随机生成
- (IBAction)btncheck2:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self readNSUserDefaults];
    
    //1.获取授权状态
    ABAuthorizationStatus type =  ABAddressBookGetAuthorizationStatus();
    //授权申请
    if (type == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"授权允许");
            }else{
                NSLog(@"授权拒绝");
            }
        });
        //释放book
        CFRelease(book);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//从NSUserDefaults中读取数据
-(void)readNSUserDefaults
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    
    //读取数据到各个label中
    //读取整型int类型的数据
    self.iHistoryCount = [userDefaultes integerForKey:@"iHistoryCount"];
    NSLog(@"readNSUserDefaults -- %d",self.iHistoryCount);
    self.historyCount.text = [NSString stringWithFormat:@"%d",self.iHistoryCount];
}

//保存数据到NSUserDefaults
-(void)saveNSUserDefaults
{
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    //NSLog(@"saveNSUserDefaults  --- %d", [self.importCount.text intValue]);
    //self.iHistoryCount = [self.importCount.text intValue] + self.iHistoryCount;
    [userDefaults setInteger:self.iHistoryCount forKey:@"iHistoryCount"];
    
    //这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    
}

- (NSArray *)arrayPhone
{
    
    if (_arrayPhone == nil) {
        NSError *error;
        NSString *textFileContentsPhone = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"phone" ofType:@"txt"] encoding:NSUTF8StringEncoding error: &error];
        if(textFileContentsPhone == nil)
        {
            return nil;
        }
        _arrayPhone = [textFileContentsPhone componentsSeparatedByString:@"\n"];
    }
    return _arrayPhone;
}

- (NSArray *)arrayContact
{
    if (_arrayContact == nil) {
        NSError *error;
        NSString *textFileContentsContact = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"contact" ofType:@"txt"] encoding:NSUTF8StringEncoding error: &error];
        if(textFileContentsContact == nil)
        {
            return nil;
        }
        _arrayContact = [textFileContentsContact componentsSeparatedByString:@"\n"];
    }
    return _arrayContact;
}

- (IBAction)btnAddContact:(id)sender {
    
    
    self.errorMsg.text = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    
    if(self.arrayPhone == nil)
    {
        self.errorMsg.text = @"找不到号码文件phone.txt，或者文件里面没数据！";
        self.view.backgroundColor = [UIColor redColor];
        return;
    }
    
    if (self.check2.selected == YES) {
        if(self.arrayContact == nil)
        {
            self.errorMsg.text = @"找不到姓名文件contact.txt，或者文件里面没数据！";
            self.view.backgroundColor = [UIColor redColor];
            return;
        }
    }
    NSInteger iImportCount = [self.importCount.text intValue];
    if(iImportCount < 1)
    {
        self.errorMsg.text = @"批次导入数量必须大于0！";
        self.view.backgroundColor = [UIColor redColor];
        return;
    }
    
    //如果历史数量+当前导入数量>号码数组数量，则报错
    if (self.iHistoryCount + iImportCount > [self.arrayPhone count]) {
        self.errorMsg.text =[NSString stringWithFormat:@"失败：批次导入数量[%d]大于号码剩于数量[%d]！",iImportCount,[self.arrayPhone count]-self.iHistoryCount];
        self.view.backgroundColor = [UIColor redColor];
        return;
    }
    
    
    NSInteger iMaxCount =self.iHistoryCount + iImportCount;
    NSLog(@"iMaxCount----%ld",iMaxCount);
    for (NSInteger index=self.iHistoryCount; index < iMaxCount; index ++) {
        NSString *phone = [self.arrayPhone objectAtIndex:index];
        [self addContact:phone];
    }
    self.iHistoryCount = iMaxCount;
    [self saveNSUserDefaults];
    NSLog(@"iHistoryCount----%ld",self.iHistoryCount);
    NSString *cCount =[NSString stringWithFormat:@"%ld",self.iHistoryCount];
    self.historyCount.text = cCount;
    self.errorMsg.text = @"批量导入数据成功！";
    self.view.backgroundColor = [UIColor greenColor];
}
- (IBAction)btnClearHistory:(id)sender {
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:0 forKey:@"iHistoryCount"];
    //这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    self.historyCount.text = @"0";
    self.iHistoryCount = 0;
    self.errorMsg.text = @"清空历史成功！";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)btnCheck1:(id)sender {
    self.check1.selected = !self.check1.selected;
    if (self.check1.selected == YES) {
        self.check2.selected = NO;
    }
}

- (IBAction)btncheck2:(id)sender {
    self.check2.selected = !self.check2.selected;
    if (self.check2.selected == YES) {
        self.check1.selected = NO;
    }
}


- (IBAction)btnClearContact:(id)sender {
    // 初始化并创建通讯录对象，记得释放内存
    ABAddressBookRef addressBook =ABAddressBookCreate();
    // 获取通讯录中所有的联系人
    NSArray *array = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 遍历所有的联系人并删除
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        //(这里只删除姓名为张三的)
        //NSString *firstName = (NSString*)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        //NSString *lastName = (NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
        //if ([firstName isEqualToString:@"三"] &&[lastName isEqualToString:@"张"]) {
            ABAddressBookRemoveRecord(addressBook, people,NULL);
        //}
    }
    // 保存修改的通讯录对象
    ABAddressBookSave(addressBook, NULL);
    // 释放通讯录对象的内存
    if (addressBook) {
        CFRelease(addressBook);
    }

    self.errorMsg.text = @"清空通讯录成功！";
    self.view.backgroundColor = [UIColor whiteColor];
}

/**
 *  添加通讯录
 *
 *  @param phone 手机号码
 */
-(void)addContact:(NSString* )phone{
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
    
    //姓名默认为手机号
    if (self.check1.selected == YES) {
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)phone, &error);
    }
    //姓名根据文件中的数据随机生成
    if (self.check2.selected == YES) {
        int r = arc4random() % [self.arrayContact count];
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)[self.arrayContact objectAtIndex:r], &error);
    }
    
    //创建一个多值属性(电话)
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)phone, kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multi, &error);
    
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    ABAddressBookSave(iPhoneAddressBook, &error);
    CFRelease(newPerson);
    CFRelease(iPhoneAddressBook);

    NSLog(@"添加成功！---%@",phone);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.importCount resignFirstResponder];
}
@end
