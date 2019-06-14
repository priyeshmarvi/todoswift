//
//  Detail.swift
//  TODOAPP
//
//  Created by icanstudioz on 13/06/19.
//  Copyright © 2019 icanstudioz.com. All rights reserved.
//


class Detail {
    let id: String?
    var title: String
    var date: String
    var description: String
    
    init(id: String) {
        self.id = id
        title = ""
        date = ""
        description = ""
    }
    
    init(id: String, title: String, date: String, description: String) {
        self.id = id
        self.title = title
        self.date = date
        self.description = description
    }
    
}



