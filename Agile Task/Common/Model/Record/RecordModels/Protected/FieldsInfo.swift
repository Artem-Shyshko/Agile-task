//
//  FieldsInfo.swift
//  Agile Password
//
//  Created by USER on 08.04.2024.
//

import RealmSwift

enum FieldsInfo: Hashable {
    case title(String)
    case password(String)
    case email(String)
    case url(String)
    case number(String)
    case date(String)
    case bulletList([BulletDTO])
    case address(String)
    case phone(String)
}
