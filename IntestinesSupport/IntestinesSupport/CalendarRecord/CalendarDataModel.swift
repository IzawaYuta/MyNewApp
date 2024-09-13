//
//  CalendarDataModel.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/08/13.
//

import RealmSwift

protocol CalendarViewControllerDelegate: AnyObject {
    func saveCalendarData(_ calendar: CalendarDataModel)
}

class CalendarDataModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date: Date = Date()
    // 99の番号は未選択状態を表す
    @objc dynamic var selectedPhysicalConditionIndex: Int = 99
    @objc dynamic var selectedFecesConditionIndex: Int = 99
    @objc dynamic var medicineRecord: MedicineRecordDataModel? // このプロパティを追加
    @objc dynamic var memo: String = ""
    
    convenience init(id: String, date: Date, selectedPhysicalConditionIndex: Int, selectedFecesConditionIndex: Int, medicineRecord: MedicineRecordDataModel? = nil, memo: String) {
        // まずself.init()を呼び出して、デフォルトの初期化を行う
        self.init()
        self.id = id
        self.date = date
        self.selectedPhysicalConditionIndex = selectedPhysicalConditionIndex
        self.selectedFecesConditionIndex = selectedFecesConditionIndex
        self.medicineRecord = medicineRecord
        self.memo = memo
    }
}

class FecesDetailDataModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var time: Date = Date()
    // 1回目とかのNo
//    @objc dynamic var number: Int = 0
    let fecesDetailTypeObject = List<FecesDetailTypeObject>()
    
    convenience init(date: Date, fecesDetailTypeRowValues: [Int], time: Date) {
        self.init()
        self.id = UUID().uuidString
        self.date = date
        self.time = time
//        self.number = number
        let object = fecesDetailTypeRowValues.map({ FecesDetailTypeObject(index: $0) })
        self.fecesDetailTypeObject.append(objectsIn: object)
    }
}

class FecesDetailTypeObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var fecesDetailConditionIndex: Int = 99
    
    convenience init(index: Int) {
        self.init()
        self.id = UUID().uuidString
        fecesDetailConditionIndex = index
    }
}

class MedicineRecordDataModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var medicineName: String = ""
    @objc dynamic var timePicker: Date = Date()
    @objc dynamic var textField: Int = 0
    @objc dynamic var unit: String = ""
    
    override init() {
            super.init()
        }
    override static func primaryKey() -> String? {
            return "id" // プライマリーキーの指定
        }
    
    convenience init(id: String, medicineName: String, timePicker: Date, textField: Int, unit: String) {
        self.init()
        self.id = id
        self.medicineName = medicineName
        self.timePicker = timePicker
        self.textField = textField
        self.unit = unit
    }
}
