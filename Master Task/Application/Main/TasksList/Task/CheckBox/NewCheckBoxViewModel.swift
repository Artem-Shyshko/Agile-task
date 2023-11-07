//
//  NewCheckBoxViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 30.10.2023.
//

import Foundation
import RealmSwift

final class NewCheckBoxViewModel: ObservableObject {
    @Published var checkBoxes = [CheckBoxObject(title: "")]
    let realm = try! Realm()
    
    func onSubmit(checkBoxesCount: Int, textFieldIndex: Int, focusedInput: inout Int?) {
        if textFieldIndex < checkBoxesCount {
          focusedInput = textFieldIndex + 1
        } else {
          focusedInput = nil
        }
    }
}
