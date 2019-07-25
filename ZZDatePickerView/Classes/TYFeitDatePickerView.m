//
//  TYFeitDatePickerView.m
//  DatePickerDemo
//
//  Created by 周晓瑞 on 2019/7/11.
//  Copyright © 2019 apple. All rights reserved.
//

#import "TYFeitDatePickerView.h"

typedef enum : NSUInteger {
    TYDateSectionHour = 0,
    TYDateSectionMinute,
    TYDateSectionApm,
} TYDateSection;

static NSInteger const kTimeMaxSeperateValue = 12;

@interface TYFeitDatePickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,strong)UIPickerView * pickerView;

@property (nonatomic,strong) NSArray <NSString *>*hourArray;
@property (nonatomic,strong) NSArray <NSString *>*minuteArray;
@property (nonatomic, strong) NSArray <NSString *>*apmArray;
@property (nonatomic,strong)  NSMutableArray <NSArray *>*timeArrays;

// 当前小时与分钟上下午
@property(nonatomic,copy)NSString *currentHour;
@property(nonatomic,copy)NSString *currentMinute;
@property(nonatomic,copy)NSString *currentApm;

@end

@implementation TYFeitDatePickerView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commitData];
        [self initPickerView];
        [self addNotifacation];
    }
    return self;
}

#pragma mark - 初始化

- (void)layoutSubviews{
    [super layoutSubviews];

    self.pickerView.frame = self.bounds;
}

- (void)initPickerView{
    [self addSubview:self.pickerView];
}

- (void)commitData {
    self.currentHour = self.hourArray.firstObject;
    self.currentMinute = self.minuteArray.firstObject;
    self.currentApm = [TYDatePTimeModel currentHour12Mode]  ? self.apmArray.firstObject : nil;
}

- (void)addNotifacation {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadPickerView) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadPickerView) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Public

- (void)setDate:(NSDate *)date {
    _date = date;

    NSArray * timeArray = [self splitTimeArray:date];

    self.currentHour = timeArray.firstObject;
    self.currentMinute = timeArray[1];
    [self reloadPickerView];
}

#pragma mark - UIPickerViewDataSource,UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.timeArrays.count;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger result = 0;
    switch (component) {
        case TYDateSectionHour:
            result = self.hourArray.count;
            break;
        case TYDateSectionMinute:
            result = self.minuteArray.count;
            break;
        default:
            result = self.apmArray.count;
            break;
    }
    return result;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = @"";
    switch (component) {
            case TYDateSectionHour: {
                title = self.hourArray[row];
                self.currentHour = title;

                int val = [title intValue];
                 [self updateApm:val];

                if (val > kTimeMaxSeperateValue && [TYDatePTimeModel currentHour12Mode]) {
                    int resultVa = val - kTimeMaxSeperateValue;
                    title = [NSString stringWithFormat:@"%d",resultVa];
                }

                break;
            }
            case TYDateSectionMinute: {
                title = self.minuteArray[row];
                self.currentMinute = title;
                break;
            }
           default: {
               title = self.apmArray[row];
               [self updateApm:[self.currentHour intValue]];
               break;
           }
    }

    if (self.pickerViewDelegate &&
        [self.pickerViewDelegate respondsToSelector:@selector(pickerView:titleForRow:)]) {
        [self.pickerViewDelegate pickerView:self titleForRow:self.currentTimeModel];
    }

    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == TYDateSectionHour) {
        self.currentHour = self.hourArray[row];
        [self updateApm:[self.currentHour intValue]];
    }else if(component == TYDateSectionMinute){
        self.currentMinute = self.minuteArray[row];
    }else{
      
    }

    if (self.pickerViewDelegate &&
        [self.pickerViewDelegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
        [self.pickerViewDelegate pickerView:self didSelectRow:self.currentTimeModel];
    }
}

#pragma mark - Private

- (void)reloadPickerView {
    self.timeArrays = nil;
    [self.pickerView reloadAllComponents];
    [self.pickerView selectRow:[self.currentHour intValue] inComponent:0 animated:NO];
    [self.pickerView selectRow:[self.currentMinute intValue] inComponent:1 animated:NO];

    [self updateApm:[self.currentHour intValue]];
}

- (TYDatePTimeModel *)currentTimeModel {
    NSInteger hour = self.currentHour.integerValue;
    NSInteger minute = self.currentMinute.integerValue;
    return [TYDatePTimeModel dateTPTime:hour minute:minute apm:self.currentApm];
}

- (void)updateApm:(int)hour {
    if (![TYDatePTimeModel currentHour12Mode]) return;

    if (hour >= kTimeMaxSeperateValue) {
        [self.pickerView selectRow:1 inComponent:TYDateSectionApm animated:NO];
        self.currentApm = self.apmArray.lastObject;
    }else{
        [self.pickerView selectRow:0 inComponent:TYDateSectionApm animated:NO];
        self.currentApm = self.apmArray.firstObject;
    }
}

- (NSArray *)splitTimeArray:(NSDate *)date {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"HH:mm:a"];
    NSString *resultFromDate = [inputFormatter stringFromDate:date];
    return  [resultFromDate componentsSeparatedByString:@":"];
}

#pragma mark - getter

- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc]init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (NSArray *)hourArray {
    if (_hourArray == nil) {
        _hourArray = @[@"00",@"1", @"2", @"3", @"4", @"5", @"6", @"7",
                           @"8", @"9", @"10", @"11", @"12", @"13", @"14",
                           @"15", @"16", @"17", @"18", @"19", @"20", @"21",
                           @"22", @"23"];
    }
    return _hourArray;
}

- (NSArray *)minuteArray {
    if (_minuteArray == nil) {
        _minuteArray = @[@"00", @"01", @"02", @"03", @"04", @"05", @"06",@"07",
                             @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15",
                             @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23",
                             @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31",
                             @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
                             @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47",
                             @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55",
                         @"56", @"57", @"58", @"59"];
    }
    return _minuteArray;
}

- (NSArray *)apmArray {
    if (_apmArray == nil) {
        _apmArray = @[@"AM",@"PM"];
    }
    return _apmArray;
}

- (NSMutableArray *)timeArrays {
    if (_timeArrays == nil) {
        _timeArrays = [NSMutableArray arrayWithObjects:self.hourArray,self.minuteArray, nil];
        if ([TYDatePTimeModel currentHour12Mode]) {
            [_timeArrays addObject:self.apmArray];
        }
    }
    return _timeArrays;
}

@end


@implementation TYDatePTimeModel

+ (instancetype)dateTPTime:(NSInteger)hour minute:(NSInteger)minute apm:(NSString *)apm {
    TYDatePTimeModel * model = [[TYDatePTimeModel alloc]init];
    model.hour = MAX(0, hour);
    model.minute = MAX(0, minute);
    model.apm = apm;
    return model;
}

+ (BOOL)currentHour12Mode {
    NSString *formatStringForHours=[NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA=[formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM=containsA.location!=NSNotFound;
    return hasAMPM;
}

@end
