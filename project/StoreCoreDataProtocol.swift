//
//  StoreCoreDataProtocol.swift
//  project
//
//  Created by Thanh Nguyen on 11/4/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import Foundation

protocol StoreCoreDataProtocol {
    func saveCoreData(data: Dictionary<String, String>)
    func updateCoreData(data: Dictionary<String, String>)
}