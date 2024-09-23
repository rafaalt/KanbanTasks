//
//  HomeView.swift
//  KanbanTasks
//
//  Created by Rafael Torga on 16/08/24.
//

import SwiftUI

struct HomeView: View {
    
    //MARK: - PRIVATE PROPERTIES
    
    @State private var todo: [Task] = [
        .init(title: "Edit Video", status: .todo)
    ]
    @State private var working: [Task] = [
        .init(title: "Watch a Game", status: .working)
    ]
    @State private var completed: [Task] = [
        .init(title: "Make an App", status: .completed),
        .init(title: "New Task", status: .completed)
    ]
    @State private var currentlyDragging: Task?

    var body: some View {
        HStack(spacing: 2) {
            TodoView()
            WorkingView()
            CompletedView()
        }
    }
    
    @ViewBuilder
    func TasksView(_ tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(tasks) { task in
                GeometryReader {
                    TaskRow(task, $0.size)
                }
                .frame(height: 45)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    func TaskRow(_ task: Task, _ size: CGSize) -> some View {
        Text(task.title)
            .font(.callout)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: size.height)
            .foregroundStyle(.pink)
            .bold()
            .background(.white, in: .rect(cornerRadius: 10))
            .contentShape(.dragPreview, .rect(cornerRadius: 10))
            .draggable(task.id.uuidString) {
                Text(task.title)
                    .font(.callout)
                    .padding(.horizontal, 15)
                    .foregroundStyle(.pink)
                    .bold()
                    .frame(width: size.width, height: size.height, alignment: .leading)
                    .background(.white, in: .rect(cornerRadius: 10))
                    .contentShape(.dragPreview, .rect(cornerRadius: 10))
                    .onAppear {
                        currentlyDragging = task
                    }
            }
            .dropDestination(for: String.self) { items, location in
                currentlyDragging = nil
                return false
            } isTargeted: { status in
                if let currentlyDragging, status, currentlyDragging.id != task.id {
                    withAnimation(.snappy) {
                        appendTask(task.status)
                        switch task.status {
                        case .todo:
                            replaceItem(tasks: &todo, droppingTask: task, status: .todo)
                        case .working:
                            replaceItem(tasks: &working, droppingTask: task, status: .working)
                        case .completed:
                            replaceItem(tasks: &completed, droppingTask: task, status: .completed)
                        }
                    }
                }
            }
    }
    
    func appendTask(_ status: Status) {
        if let currentlyDragging {
            switch status {
            case .todo:
                if !todo.contains(where: { $0.id == currentlyDragging.id }) {
                    var updateTask = currentlyDragging
                    updateTask.status = .todo
                    todo.append(updateTask)
                    working.removeAll(where: { $0.id == currentlyDragging.id})
                    completed.removeAll(where: {$0.id == currentlyDragging.id})
                }
            case .working:
                if !working.contains(where: { $0.id == currentlyDragging.id }) {
                    var updateTask = currentlyDragging
                    updateTask.status = .working
                    working.append(updateTask)
                    todo.removeAll(where: { $0.id == currentlyDragging.id})
                    completed.removeAll(where: {$0.id == currentlyDragging.id})
                }
            case .completed:
                if !completed.contains(where: { $0.id == currentlyDragging.id }) {
                    var updateTask = currentlyDragging
                    updateTask.status = .completed
                    completed.append(updateTask)
                    working.removeAll(where: { $0.id == currentlyDragging.id})
                    todo.removeAll(where: {$0.id == currentlyDragging.id})
                }
            }
        }
    }
    
    func replaceItem(tasks: inout [Task], droppingTask: Task, status: Status) {
        if let currentlyDragging {
            if let sourceIndex = tasks.firstIndex(where: { $0.id == currentlyDragging.id }),
               let destinationIndex = tasks.firstIndex(where: { $0.id == droppingTask.id}) {
                var sourceItem = tasks.remove(at: sourceIndex)
                sourceItem.status = status
                tasks.insert(sourceItem, at: destinationIndex)
            }
        }
    }
    
    //MARK: - VIEWS
    
    @ViewBuilder
    func TodoView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(todo)
            }
            .navigationTitle("Todo")
            .frame(maxWidth: .infinity)
            .background(.pink)
            .dropDestination(for: String.self) { items, location in
                withAnimation(.snappy) {
                    appendTask(.todo)
                }
                return true
            } isTargeted: { _ in
                
            }
        }
    }
    
    @ViewBuilder
    func WorkingView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(working)
            }
            .navigationTitle("Working")
            .frame(maxWidth: .infinity)
            .background(.pink)
            .contentShape(.rect)
            .dropDestination(for: String.self) { items, location in
                withAnimation(.snappy) {
                    appendTask(.working)
                }
                return true
            } isTargeted: { _ in
                
            }
        }
    }
    
    @ViewBuilder
    func CompletedView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(completed)
            }
            .navigationTitle("Completed")
            .frame(maxWidth: .infinity)
            .background(.pink)
            .dropDestination(for: String.self) { items, location in
                withAnimation(.snappy) {
                    appendTask(.completed)
                }
                return true
            } isTargeted: { _ in
                
            }
        }
    }
}

#Preview {
    HomeView()
}
