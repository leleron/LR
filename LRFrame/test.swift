//
//  test.swift
//  LRFrame
//
//  Created by 李荣 on 16/3/29.
//  Copyright © 2016年 leron. All rights reserved.
//

import Foundation

class test: NSObject {

    var meme = 1

internal var memeda = 2
    
    
    
func iss() -> Int {
    let qutation = "leron"
    let qutation2 = "leron"
    var count = 0
    let array = [qutation,qutation2]
    for item in array {
        if item == "leron" {
            count += 1;
        }
    }
//    countElements(qutation2)
    if qutation == qutation2 {
        return 2
    }
return 0
}
    
    
}