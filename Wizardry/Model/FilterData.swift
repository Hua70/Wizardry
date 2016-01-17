//
//  FilterData.swift
//  Wizardry
//
//  Created by YWH on 16/1/17.
//  Copyright © 2016年 YWH. All rights reserved.
//

import UIKit

class FilterData: NSObject {
    let filterDescriptors: [(filterName: String, filterDisplayName: String)] = [
        ("CIColorControls", "None"),
        ("CIPhotoEffectMono", "Mono"),  //单色
        ("CIPhotoEffectTonal", "Tonal"),  //色调
        ("CIPhotoEffectNoir", "Noir"),    //黑白
        ("CIPhotoEffectFade", "Fade"),   //褪色
        ("CIPhotoEffectChrome", "Chrome"),  //铬黄
        ("CIPhotoEffectProcess", "Process"), //冲印
        ("CIPhotoEffectTransfer", "Transfer"),  //岁月
        ("CIPhotoEffectInstant", "Instant"), //怀旧
        ("CIColorInvert", "Invert")
    ]
}
