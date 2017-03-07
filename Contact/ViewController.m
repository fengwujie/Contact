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
#import <ContactsUI/ContactsUI.h>

#define IS_iOS9 [[UIDevice currentDevice].systemVersion floatValue] >= 9.0f
#define IS_iOS8 [[UIDevice currentDevice].systemVersion floatValue] >= 8.0f
#define IS_iOS6 [[UIDevice currentDevice].systemVersion floatValue] >= 6.0f

@interface ViewController ()
/**
 *  历史数量Lable控件
 */
@property (weak, nonatomic) IBOutlet UILabel *historyCount;
/**
 *  批次导入数量值Text控件
 */
@property (weak, nonatomic) IBOutlet UITextField *importCount;
/**
 *  姓名默认为手机号CHK控件
 */
@property (weak, nonatomic) IBOutlet UIButton *check1;
/**
 *  姓名随机生成CHK控件
 */
@property (weak, nonatomic) IBOutlet UIButton *check2;
/**
 *  错误信息显示Lable控件
 */
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
@property (weak, nonatomic) IBOutlet UITextField *phoneTxtName;

/**
 *  历史数量
 */
@property (assign, nonatomic) NSInteger iHistoryCount;
/**
 *  电话号码数组
 */
@property (strong,nonatomic) NSArray *arrayPhone;
/**
 *  姓名数组
 */
@property (strong,nonatomic) NSArray *arrayContact;
/**
 *  默认电话号码数组
 */
@property (strong,nonatomic) NSArray *arrayPhoneDefault;
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
/**
 *  版本号
 */
@property (weak, nonatomic) IBOutlet UILabel *labVersion;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.labVersion.text = [NSString stringWithFormat:@"版本号(%@)",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    [self readNSUserDefaults];
    
    /*
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
    */
    
    
    //判断是否已经授权
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if ( status == CNAuthorizationStatusAuthorized)
    {
        //如果已经授权，直接返回
        return;
    }
    else
    {
        //iOS9授权
        if(IS_iOS9)
        {
            CNContactStore *store = [[CNContactStore alloc] init];
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"error=%@",error);
                }
                if (granted) {
                    NSLog(@"授权成功");
                }else{
                    NSLog(@"授权失败");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"授权失败" message:@"请在设置中打开访问权限" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alert show];
                }
                
            }];
        }
        //iOS8授权方式
        else if(IS_iOS8)
        {
             //创建通讯录
             ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
             //请求授权
             ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
                 if (granted) {
                     NSLog(@"授权成功");
                 }else{
                     NSLog(@"授权失败");
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"授权失败" message:@"请在设置中打开访问权限" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                     [alert show];
                 }
             });
        }
        else if(IS_iOS6)
        {
            ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    NSLog(@"授权允许");
                }else{
                    NSLog(@"授权拒绝");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"授权失败" message:@"请在设置中打开访问权限" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alert show];
                }
            });
            //释放book
            CFRelease(book);
        }
        // [CNContactStore requestAccessForEntityType:completionHandler:]
        
    }
    
    
    
    /*
    CFErrorRef *error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        NSLog(@"granted==%d",granted);
        
        if (granted) {
            NSLog(@"授权成功！");
            //[self getUpAddBookViewPersonDataWithAddBook:addressBook];
        } else {
            NSLog(@"授权失败!");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"授权失败" message:@"请在设置中打开访问权限" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
        
    });
     */
    
    /*
    //1 判断是否授权成功
       if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) return;//授权成功直接返回
        //2 创建通讯录
        CNContactStore *store = [[CNContactStore alloc] init];
        //3授权
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    NSLog(@"授权成功");
                     }else{
                             NSLog(@"授权失败");
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"授权失败" message:@"请在设置中打开访问权限" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                         [alert show];

                         }
            }];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  从NSUserDefaults中读取数据
 *
 *  @param loadLastPhoneTxtName 是否重新赋值最后一次保存的电话本文件名
 */
-(void)readNSUserDefaults
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    self.phoneTxtName.text =[userDefaultes valueForKey:@"lastPhoneTxtName"];
    if([self.phoneTxtName.text isEqual:@""])
        self.phoneTxtName.text = @"phone";
    self.defaultTxtName.text =[userDefaultes valueForKey:@"lastDefaultTxtName"];
    if([self.defaultTxtName.text isEqual:@""])
        self.defaultTxtName.text = @"default";
    //读取数据到各个label中
    //读取整型int类型的数据
    self.iHistoryCount = [userDefaultes integerForKey:[NSString stringWithFormat:@"iHistoryCount%@",self.phoneTxtName.text]];
    NSLog(@"readNSUserDefaults -- %ld",(long)self.iHistoryCount);
    self.historyCount.text =self.iHistoryCount == 0 ? 0 : [NSString stringWithFormat:@"%ld",(long)self.iHistoryCount];
    
    NSInteger imaxCount =[userDefaultes integerForKey:[NSString stringWithFormat:@"iMaxCount%@",self.phoneTxtName.text]];
    self.maxCount.text =imaxCount == 0 ? @"" : [NSString stringWithFormat:@"%ld",(long)imaxCount];
    if ([self.maxCount.text isEqual:@""]) {
        self.maxCount.text = @"0";
    }
    NSInteger iBatchCount =[userDefaultes integerForKey:[NSString stringWithFormat:@"iBatchCount%@",self.phoneTxtName.text]];
    self.importCount.text =iBatchCount == 0 ? @"" : [NSString stringWithFormat:@"%ld",(long)iBatchCount];
    if ([self.importCount.text isEqual:@""]) {
        self.importCount.text = @"0";
    }
    self.check1.selected = [userDefaultes boolForKey:@"check1"];
    self.check2.selected = [userDefaultes boolForKey:@"check2"];
}

//保存数据到NSUserDefaults
-(void)saveNSUserDefaults
{
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    //NSLog(@"saveNSUserDefaults  --- %d", [self.importCount.text intValue]);
    //self.iHistoryCount = [self.importCount.text intValue] + self.iHistoryCount;
    [userDefaults setInteger:self.iHistoryCount forKey: [NSString stringWithFormat:@"iHistoryCount%@",self.phoneTxtName.text]];
    [userDefaults setInteger:[self.maxCount.text intValue] forKey:[NSString stringWithFormat:@"iMaxCount%@",self.phoneTxtName.text]];
    [userDefaults setInteger:[self.importCount.text intValue] forKey:[NSString stringWithFormat:@"iBatchCount%@",self.phoneTxtName.text]];
    [userDefaults setValue:self.phoneTxtName.text forKey:@"lastPhoneTxtName"];
    [userDefaults setValue:self.defaultTxtName.text forKey:@"lastDefaultTxtName"];
    
    [userDefaults setBool:self.check1.selected forKey:@"check1"];
    [userDefaults setBool:self.check2.selected forKey:@"check2"];
    //这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    
}
/**
 *  缓存默认电话号码数组
 */
- (NSArray *)arrayPhoneDefault
{
    if (_arrayPhoneDefault == nil) {
        NSString *strDefaultTxtName = self.defaultTxtName.text;
        if(strDefaultTxtName.length ==0) return nil;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:strDefaultTxtName ofType:@"txt"];
        if(filePath == nil)
        {
            self.errorMsg.text = [NSString stringWithFormat:@"文件%@不存在！",strDefaultTxtName];
            self.view.backgroundColor = [UIColor redColor];
            return nil;
        }
        NSError *error;
        NSString *textFileContentsPhone = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: &error];
        if(textFileContentsPhone == nil)
        {
            self.errorMsg.text = [NSString stringWithFormat:@"文件%@没数据！",strDefaultTxtName];
            self.view.backgroundColor = [UIColor redColor];
            return nil;
        }
        _arrayPhoneDefault = [textFileContentsPhone componentsSeparatedByString:@"\n"];
    }
    return _arrayPhoneDefault;
}
/**
 *  缓存电话号码数组
 */
- (NSArray *)arrayPhone
{
    if (_arrayPhone == nil) {
        NSString *strPhoneTxtName = self.phoneTxtName.text;
        if(strPhoneTxtName.length ==0) return nil;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:strPhoneTxtName ofType:@"txt"];
        if(filePath == nil)
        {
            self.errorMsg.text = [NSString stringWithFormat:@"文件%@不存在！",strPhoneTxtName];
            self.view.backgroundColor = [UIColor redColor];
            return nil;
        }

        NSError *error;
        NSString *textFileContentsPhone = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: &error];
        if(textFileContentsPhone == nil)
        {
            self.errorMsg.text = [NSString stringWithFormat:@"文件%@没数据！",strPhoneTxtName];
            self.view.backgroundColor = [UIColor redColor];
            return nil;
        }
        _arrayPhone = [textFileContentsPhone componentsSeparatedByString:@"\n"];
    }
    return _arrayPhone;
}
/**
 *  缓存联系人数组
 */
- (NSArray *)arrayContact
{
    if (_arrayContact == nil) {
        NSError *error;
        NSString *textFileContentsContact = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"contact" ofType:@"txt"] encoding:NSUTF8StringEncoding error: &error];
        if(textFileContentsContact == nil)
        {
            self.errorMsg.text = @"找不到姓名文件contact.txt，或者文件里面没数据！";
            self.view.backgroundColor = [UIColor redColor];
            return nil;
        }
        _arrayContact = [textFileContentsContact componentsSeparatedByString:@"\n"];
    }
    return _arrayContact;
}

- (IBAction)btnAddContact:(id)sender {
    
    
    self.errorMsg.text = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //如果当前通讯录文件名跟参数保存的不一样，则清空电话数组
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if (self.phoneTxtName.text !=[userDefaultes valueForKey:@"lastPhoneTxtName"])
    {
        _arrayPhone =nil;
        self.iHistoryCount = [userDefaultes integerForKey:[NSString stringWithFormat:@"iHistoryCount%@",self.phoneTxtName.text]];
        NSLog(@"readNSUserDefaults -- %ld",(long)self.iHistoryCount);
        self.historyCount.text =self.iHistoryCount == 0 ? 0 : [NSString stringWithFormat:@"%ld",(long)self.iHistoryCount];
    }
    if(self.defaultTxtName.text !=[userDefaultes valueForKey:@"lastDefaultTxtName"])
        _arrayPhoneDefault = nil;
    
//    if((self.arrayPhone == nil || self.arrayPhone.count==0) && (self.arrayPhoneDefault==nil || self.arrayPhoneDefault.count==0))
//    {
//        self.errorMsg.text =@"【默认导入文件名】和【通讯录来源文件名】都不存在号码！";
//        self.view.backgroundColor = [UIColor redColor];
//        return;
//    }
    if (self.arrayPhone == nil || self.arrayPhone.count==0) {
        return;
    }
    if(self.arrayPhoneDefault == nil || self.arrayPhoneDefault.count == 0)
    {
        return;
    }
    
    
    if (self.check2.selected == YES) {
        if(self.arrayContact == nil)
        {
//            self.errorMsg.text = @"找不到姓名文件contact.txt，或者文件里面没数据！";
//            self.view.backgroundColor = [UIColor redColor];
            return;
        }
    }
    NSInteger iBatchCount = [self.importCount.text intValue];
    //批次导入数量为0时，也允许导入，单单只导入默认文件的电话号码20170103
//    if(iBatchCount < 1)
//    {
//        self.errorMsg.text = @"批次导入数量必须大于0！";
//        self.view.backgroundColor = [UIColor redColor];
//        return;
//    }
    //添加默认手机号码
    [self addDefaultContact];
    
//    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
//    //读取数据到各个label中
//    //读取整型int类型的数据
//    self.iHistoryCount = [userDefaultes integerForKey:[NSString stringWithFormat:@"iHistoryCount%@",self.phoneTxtName.text]];
//    NSLog(@"readNSUserDefaults -- %ld",(long)self.iHistoryCount);
//    self.historyCount.text =self.iHistoryCount == 0 ? 0 : [NSString stringWithFormat:@"%ld",(long)self.iHistoryCount];
    
    if(_arrayPhone.count>0)
    {
        //如果历史数量>=电话数组数量，则提示“通讯录xx已全部导入完成，或清空历史记录重试”
        if(self.iHistoryCount >= self.arrayPhone.count)
        {
            self.errorMsg.text = [NSString stringWithFormat:@"通讯录[%@]已全部导入完成，或清空历史记录重试！",self.phoneTxtName.text];
            self.view.backgroundColor = [UIColor redColor];
            return;
        }
        NSInteger iMaxCount = [self.maxCount.text intValue];  //上限数量
        NSInteger iBeginIndex =0;
        NSInteger iEndIndex=0;
        NSInteger iArrayPhoneTemp =self.arrayPhone.count;
        NSLog([NSString stringWithFormat:@"arrayphone的数量%ld",(long)iArrayPhoneTemp]);
        //如果历史数量<上限数量
        if(_iHistoryCount<iMaxCount)
        {
            NSInteger iDiffCount = iMaxCount - _iHistoryCount;  //上限数量 减去 历史数量的差距
            //如果差距数量>批次导入数量
            if(iDiffCount > iBatchCount)
            {
                //如果（历史数量+批次导入数量）>=电话总数
                if((_iHistoryCount + iBatchCount) <= iArrayPhoneTemp)
                {
                    iBeginIndex = 0;
                    iEndIndex = _iHistoryCount + iBatchCount;
                }
                else
                {
                    iBeginIndex = 0;
                    iEndIndex = iArrayPhoneTemp;
                }
            }
            else
            {
                //（如果历史数量+批次导入的数量）>电话总数
                if((_iHistoryCount + iBatchCount)>iArrayPhoneTemp)
                {
                    iBeginIndex = 0;
                    iEndIndex = iArrayPhoneTemp;
                }
                else
                {
                    iBeginIndex =_iHistoryCount + iBatchCount - iMaxCount;
                    iEndIndex =_iHistoryCount + iBatchCount;
                }
            }
        }
        else
        {
            NSInteger iDiffCount = _iHistoryCount - iMaxCount;  //历史数量 减去 上限数量的差距
            iBeginIndex = iDiffCount + iBatchCount;
            //如果(历史数量+批次导入数量)>电话总数
            if((_iHistoryCount + iBatchCount) < iArrayPhoneTemp)
            {
                iEndIndex = _iHistoryCount + iBatchCount;
            }
            else
            {
                iEndIndex = iArrayPhoneTemp;
            }
        }
        NSLog([NSString stringWithFormat:@"ibeginIndex=%ld,iEndIndex=%ld",(long)iBeginIndex,(long)iEndIndex]);
        for (NSInteger index=iBeginIndex; index < iEndIndex; index ++) {
            NSString *phone = [self.arrayPhone objectAtIndex:index];
            [self addContact:phone];
        }
        self.iHistoryCount = iEndIndex;
        NSString *cCount =[NSString stringWithFormat:@"%ld",(long)iEndIndex];
        self.historyCount.text = cCount;
        [self saveNSUserDefaults];
        self.errorMsg.text = @"批量导入数据成功！";
        self.view.backgroundColor = [UIColor greenColor];
    }
    else if(iBatchCount>0)
    {
        self.errorMsg.text = [NSString stringWithFormat:@"通讯录[%@]已全部导入完成，或清空历史记录重试！",self.phoneTxtName.text];
        self.view.backgroundColor = [UIColor redColor];
    }
    else
    {
        self.errorMsg.text = @"批量导入数据成功！";
        self.view.backgroundColor = [UIColor greenColor];
    }
    /*
    //如果历史数量+当前导入数量>号码数组数量，则报错
    if (self.iHistoryCount + iBatchCount > [self.arrayPhone count]) {
        self.errorMsg.text =[NSString stringWithFormat:@"失败：批次导入数量[%d]大于号码剩于数量[%d]！",iBatchCount,[self.arrayPhone count]-self.iHistoryCount];
        self.view.backgroundColor = [UIColor redColor];
        return;
    }
    
    NSInteger iMaxCount =self.iHistoryCount + iBatchCount;
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
    */
}
/**
 *  添加默认手机号码
 */
-(void)addDefaultContact
{
    if(self.arrayPhoneDefault==nil || self.arrayPhoneDefault.count==0) return;
    for (NSInteger index=0; index < self.arrayPhoneDefault.count; index ++) {
        NSString *phone = [self.arrayPhoneDefault objectAtIndex:index];
        [self addContact:phone];
    }
}

- (IBAction)btnClearHistory:(id)sender {
    if(self.phoneTxtName.text ==nil)
    {
        self.errorMsg.text = @"通讯录文件名不能为空！";
        self.view.backgroundColor = [UIColor redColor];
    }
    else
    {
        //将上述数据全部存储到NSUserDefaults中
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:0 forKey:[NSString stringWithFormat:@"iHistoryCount%@",self.phoneTxtName.text]];
        //这里建议同步存储到磁盘中，但是不是必须的
        [userDefaults synchronize];
        self.historyCount.text = @"0";
        self.iHistoryCount = 0;
        self.errorMsg.text = @"清空历史成功！";
        self.view.backgroundColor = [UIColor whiteColor];
    }
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
    
    /*
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
     */
    

    CFErrorRef error = NULL;
    //创建一个通讯录操作对象
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    //创建一条新的联系人纪录
    ABRecordRef newRecord = ABPersonCreate();
    
    //姓名默认为手机号
    if (self.check1.selected == YES) {
        ABRecordSetValue(newRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)phone, &error);
    }
    //姓名根据文件中的数据随机生成
    if (self.check2.selected == YES) {
        int r = arc4random() % [self.arrayContact count];
        //为新联系人记录添加属性值
        ABRecordSetValue(newRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)[self.arrayContact objectAtIndex:r], &error);
    }
    //创建一个多值属性(电话)
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)phone, kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(newRecord, kABPersonPhoneProperty, multi, &error);
    
    //添加记录到通讯录操作对象
    ABAddressBookAddRecord(addressBook, newRecord, &error);
    //保存通讯录操作对象
    ABAddressBookSave(addressBook, &error);
    
    CFRelease(multi);
    CFRelease(newRecord);
    CFRelease(addressBook);
    NSLog(@"添加成功！---%@",phone);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.importCount resignFirstResponder];
}
@end
