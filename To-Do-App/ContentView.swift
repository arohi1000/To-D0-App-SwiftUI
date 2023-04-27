import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var priority: TaskPriority
    var dueDate: Date?
    var completed: Bool
}

enum TaskPriority: String, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}


struct TaskRow: View {
    let task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate, formatter: DateFormatter.dateOnlyFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if task.completed {
                Image(systemName: "checkmark.square.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "square")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

struct NewTaskView: View {
    @Binding var taskList: [Task]
    @State private var newTaskTitle = ""
    @State private var newTaskPriority = TaskPriority.medium
    @State private var newTaskDueDate = Date()
    
    var body: some View {
        Form {
            TextField("Task title", text: $newTaskTitle)
            DatePicker("Due date", selection: $newTaskDueDate, displayedComponents: .date)
            Picker("Priority", selection: $newTaskPriority) {
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    Text(priority.rawValue)
                }
            }
            Button("Add task") {
                let newTask = Task(title: newTaskTitle, priority: newTaskPriority, dueDate: newTaskDueDate, completed: false)
                taskList.append(newTask)
            }
        }
        .navigationTitle("New task")
    }
}


struct EditTaskView: View {
    @State var task: Task
    @Binding var taskList: [Task]
    
    var body: some View {
        Form {
            TextField("Task title", text: $task.title)
            Picker("Priority", selection: $task.priority) {
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    Text(priority.rawValue)
                }
            }
            Toggle("Completed", isOn: $task.completed)
            Button("Save changes") {
                guard let taskIndex = taskList.firstIndex(where: { $0.id == task.id }) else {
                    fatalError("Task not found in list")
                }
                taskList[taskIndex] = task
            }
        }
        .navigationTitle("Edit task")
    }
}

struct ContentView: View {
    @State private var taskList: [Task] = []
    @State private var newTaskTitle = ""
    @State private var newTaskPriority = TaskPriority.medium
    @State private var newTaskDueDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(taskList) { task in
                    NavigationLink(destination: EditTaskView(task: task, taskList: $taskList)) {
                        TaskRow(task: task)
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .listStyle(.plain)
            .navigationBarTitle("To-Do List")
            .navigationTitle("Tasks")
            .navigationBarItems(trailing: NavigationLink(destination: NewTaskView(taskList: $taskList)) {
                Image(systemName: "plus")
            })
        }
        .background(Color("background"))
        .colorScheme(.dark)
    }
    
    func deleteTask(at offsets: IndexSet) {
        taskList.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension DateFormatter {
static let dateOnlyFormatter: DateFormatter = {
let formatter = DateFormatter()
formatter.dateStyle = .short
formatter.timeStyle = .none
return formatter
}()
}
