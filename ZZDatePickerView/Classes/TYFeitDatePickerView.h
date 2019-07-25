//
//  TYFeitDatePickerView.h
//  DatePickerDemo
//
//  Created by 周晓瑞 on 2019/7/11.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYFeitDatePickerView;
@class TYDatePTimeModel;

@protocol TYDatePickerViewDelegate <NSObject>
@optional

- (void)pickerView:(TYFeitDatePickerView *)pickerView titleForRow:(TYDatePTimeModel *)model;

- (void)pickerView:(TYFeitDatePickerView *)pickerView didSelectRow:(TYDatePTimeModel *)model;

@end


@interface TYFeitDatePickerView : UIView

@property(nonatomic, weak) id <TYDatePickerViewDelegate> pickerViewDelegate;
@property(nonatomic,strong) NSDate *date;

@end


@interface TYDatePTimeModel: NSObject

@property(nonatomic, assign) NSInteger hour;
@property(nonatomic, assign) NSInteger minute;
@property(nonatomic,copy)    NSString *apm;

+ (instancetype)dateTPTime:(NSInteger)hour minute:(NSInteger)minute apm:(NSString *)apm;

/**
 是否是12小时制

 @return 返回YES，表示当前是12小时制
 */
+ (BOOL)currentHour12Mode;

@end




