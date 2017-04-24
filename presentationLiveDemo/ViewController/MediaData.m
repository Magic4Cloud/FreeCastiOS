//
//  MediaData.m
//  Feishen
//
//  Created by rakwireless on 15/12/21.
//  Copyright © 2015年 rak. All rights reserved.
//

#import "MediaData.h"

@implementation MediaData
-(MediaData *)initWithDate:(NSString *)Date andName:(NSString *)Name andUrl:(NSString *)Url andTimesamp:(NSString *)Timesamp andImage:(NSObject *)image andFullImage:(NSObject *)fullImage{
    if(self=[super init]){
        self.Date=Date;
        self.Name=Name;
        self.Url=Url;
        self.Timesamp=Timesamp;
        self.Image=image;
        self.FullImage=fullImage;
    }
    return self;
}

-(NSString *)getName{
    return [NSString stringWithFormat:@"%@",_Name];
}

-(NSString *)getDate{
    return [NSString stringWithFormat:@"%@",_Date];
}

-(NSString *)getUrl{
    return [NSString stringWithFormat:@"%@",_Url];
}

-(NSString *)getTimesamp{
    return [NSString stringWithFormat:@"%@",_Timesamp];
}

-(NSObject *)getImage{
    return _Image;
}

-(NSObject *)getFullImage{
    return _FullImage;
}

+(MediaData *)initWithDate:(NSString *)Date andName:(NSString *)Name andUrl:(NSString *)Url andTimesamp:(NSString *)Timesamp andImage:(NSObject *)image andFullImage:(NSObject *)fullImage{
    MediaData *media=[[MediaData alloc]initWithDate:Date andName:Name andUrl:Url andTimesamp:Timesamp andImage:image andFullImage:fullImage];
    return media;
}
@end
