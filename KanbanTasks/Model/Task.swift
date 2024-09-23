//
//  Task.swift
//  KanbanTasks
//
//  Created by Rafael Torga on 16/08/24.
//

import Foundation

struct Task: Identifiable, Hashable {
    var id: UUID = .init()
    var title: String
    var status: Status
}

enum Status {
    case todo
    case working
    case completed
}
