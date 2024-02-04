import SwiftUI

enum TaskPriority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct Task: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var completed: Bool
    var priority: TaskPriority  // Added task priority property
}

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    
    func addTask(title: String, priority: TaskPriority) {
        let newTask = Task(title: title, completed: false, priority: priority)
        tasks.append(newTask)
    }
    
    func toggleTaskCompleted(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].completed.toggle()
        }
    }
    
    func removeTask(task: Task) {
        tasks.removeAll(where: { $0.id == task.id })
    }
}

class ThemeManager: ObservableObject {
    enum Theme: String, CaseIterable {
        case white = "White"
        case dark = "Dark"
        case gradient = "Gradient"
    }
    
    @Published var currentTheme: Theme = .dark
    
    var backgroundColor: Color {
        switch currentTheme {
        case .white:
            return .white
        case .dark:
            return .black
        case .gradient:
            return Color.black // Change to gradient color
        }
    }
    
    // Add more styling properties as needed
    
    func toggleTheme() {
        currentTheme = Theme.allCases.randomElement() ?? .dark
    }
}

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var themeManager = ThemeManager()
    
    @State private var newTaskTitle = ""
    @State private var selectedPriority = TaskPriority.medium // Default priority
    @State private var isShowingSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(taskManager.tasks) { task in
                        NavigationLink(destination: TaskDetail(task: $taskManager.tasks[taskManager.tasks.firstIndex(of: task)!], taskManager: taskManager)) {
                            TaskRow(task: task)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let task = taskManager.tasks[index]
                            taskManager.removeTask(task: task)
                        }
                    }
                }
                
                VStack {
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Button(action: addTask) {
                        Text("Add Task")
                    }
                    .padding()
                }
            }
            .navigationTitle("Task Manager")
            .background(themeManager.backgroundColor.edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isShowingSettings {
                        Button(action: {}) {
                            Image(systemName: "paintbrush")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(isPresented: $isShowingSettings), isActive: $isShowingSettings) {
                        Button(action: {}) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
        }
    }
    
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        taskManager.addTask(title: newTaskTitle, priority: selectedPriority)
        newTaskTitle = ""
        selectedPriority = .medium  // Reset to default priority after adding task
    }
}

struct TaskDetail: View {
    @Binding var task: Task
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        VStack {
            TextField("Title", text: $task.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Toggle("Completed", isOn: $task.completed)
                .toggleStyle(SwitchToggleStyle())
            
            Picker("Priority", selection: $task.priority) {
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    Text(priority.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
        }
        .padding()
        .navigationTitle("Edit Task")
        .navigationBarItems(trailing: Button("Save", action: saveTask))
   }

private func saveTask() {
    // No specific action needed for saving in this basic example
}

}

struct TaskRow: View {
let task: Task

var body: some View {
    HStack {
        Image(systemName: task.completed ? "checkmark.square.fill" : "square")
            .foregroundColor(task.completed ? .green : .gray)
        
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.headline)
            Text("Priority: \(task.priority.rawValue)")
                .font(.subheadline)
        }
        
        Spacer()
    }
}

}

struct SettingsView: View {
@Binding var isPresented: Bool

var body: some View {
    VStack {
        Text("Settings")
            .font(.title)
            .padding()
        
        Button("White") {
            // Change theme to white
        }
        .buttonStyle(SquareButtonStyle(color: .white))
        .padding()
        
        Button("Dark") {
            // Change theme to dark
        }
        .buttonStyle(SquareButtonStyle(color: .black))
        .padding()
        
        Button("Gradient") {
            // Change theme to gradient
        }
        .buttonStyle(SquareButtonStyle(color: .black))
        .padding()
        
        Button("Close") {
            isPresented = false
        }
        .padding()
    }
}

}

struct SquareButtonStyle: ButtonStyle {
var color: Color

func makeBody(configuration: Configuration) -> some View {
    configuration.label
        .foregroundColor(.white)
        .padding()
        .background(color)
        .cornerRadius(8)
        .opacity(configuration.isPressed ? 0.7 : 1.0)
}
}

@main
struct TaskApp: App {
var body: some Scene {
WindowGroup {
ContentView()
}
}
}
