import SwiftUI

// MARK: - Inspection Item Status Enum
enum InspectionItemStatus {
    case unselected
    case pass
    case fail
}

// MARK: - Inspection Item Model
struct DetailedInspectionItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    var status: InspectionItemStatus = .unselected
    var failureDetails: String = ""
    var attachedImage: UIImage? = nil // Stores captured photo
}

// MARK: - View Model
class DetailedInspectionViewModel: ObservableObject {
    @Published var items: [DetailedInspectionItem] = [
        DetailedInspectionItem(title: "Brakes", subtitle: "", iconName: "arrow.clockwise.heart.fill"),
        DetailedInspectionItem(title: "Tires", subtitle: "", iconName: "car.rear.and.tire.marks"),
        DetailedInspectionItem(title: "Lights", subtitle: "", iconName: "sun.max.fill"),
        DetailedInspectionItem(title: "Mirrors", subtitle: "", iconName: "eye.fill"),
        DetailedInspectionItem(title: "Engine", subtitle: "", iconName: "wrench.and.screwdriver.fill"),
        DetailedInspectionItem(title: "Fuel", subtitle: "", iconName: "fuelpump.fill")
    ]
    
    @Published var generalNotes: String = ""
    @Published var showCameraPicker: Bool = false
    @Published var activeItemForPhoto: UUID? = nil
    
    var completedCount: Int {
        items.filter { $0.status != .unselected }.count
    }
    
    var totalCount: Int {
        items.count
    }
    
    var completionPercentage: Int {
        totalCount > 0 ? (completedCount * 100) / totalCount : 0
    }
}

// MARK: - Main View
struct DetailedInspectionView: View {
    @StateObject private var viewModel = DetailedInspectionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Vehicle Info Top Header Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.05))
                            .frame(width: 48, height: 48)
                        Image(systemName: "box.truck.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vehicle #8824")
                            .font(.headline)
                            .bold()
                        Text("Volvo VNL 860 • 2024 Model")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("Active Inspection")
                                .font(.caption)
                                .foregroundColor(.green)
                                .bold()
                        }
                        .padding(.top, 2)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                
                // Progress Tracker Section
                VStack(alignment: .leading, spacing: 6) {
                    Text("CURRENT PROGRESS")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.secondary)
                    
                    HStack {
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(viewModel.completedCount)")
                                .font(.title3)
                                .bold()
                            Text("of \(viewModel.totalCount) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(viewModel.completionPercentage)% Complete")
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                    
                    ProgressView(value: Double(viewModel.completedCount), total: Double(viewModel.totalCount))
                        .tint(.blue)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
                .padding(.horizontal, 4)
            }
            .padding()
            .background(Color(.systemGroupedBackground).opacity(0.4))
            
            // 2. Scrollable Dynamic Checklist Form
            ScrollView {
                VStack(spacing: 14) {
                    ForEach($viewModel.items) { $item in
                        InspectionCardView(item: $item, onPhotoTap: {
                            viewModel.activeItemForPhoto = item.id
                            viewModel.showCameraPicker = true
                        })
                    }
                    
                    // Report Defect (Other than above) Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Report Defect (Other than above)")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // Logic to add an extra custom defect item dynamically
                        }) {
                            // Locate this inside your Checklist Form area:
                            NavigationLink(destination: ReportDefectView()) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Report Defect")
                                }
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(.blue) // Ensure button label text renders blue
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [4]))
                                )
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    // Notes & Exceptions Bottom Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES / EXCEPTIONS")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $viewModel.generalNotes)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 0.8)
                            )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).opacity(0.6))
            
            // 3. Final Submission Action Panel
            VStack(spacing: 10) {
                Button(action: {
                    // Action for final completion routing
                }) {
                    HStack {
                        Text("Submit Inspection")
                        Image(systemName: "paperplane.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
        }
        .navigationTitle("Inspection")
        .navigationBarTitleDisplayMode(.inline)
        // Camera sheet sheet binder fallback structure
        .sheet(isPresented: $viewModel.showCameraPicker) {
            ImagePickerFallback(selectedImage: Binding(
                get: {
                    viewModel.items.first(where: { $0.id == viewModel.activeItemForPhoto })?.attachedImage
                },
                set: { newImg in
                    if let idx = viewModel.items.firstIndex(where: { $0.id == viewModel.activeItemForPhoto }) {
                        viewModel.items[idx].attachedImage = newImg
                    }
                }
            ))
        }
    }
}

// MARK: - Context-Aware Interactive Card Components
struct InspectionCardView: View {
    @Binding var item: DetailedInspectionItem
    var onPhotoTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Top Title/Control Header Block
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(item.status == .fail ? Color.red.opacity(0.05) : Color.blue.opacity(0.05))
                        .frame(width: 42, height: 42)
                    Image(systemName: item.iconName)
                        .foregroundColor(item.status == .fail ? .red : .blue)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.body)
                        .bold()
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if item.status == .fail {
                    HStack(spacing: 4) {
                        Circle().fill(Color.red).frame(width: 6, height: 6)
                        Text("Failed")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.red)
                    }
                }
                
                Image(systemName: item.status == .fail ? "chevron.up" : "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Pass/Fail Selector Button Controls
            HStack(spacing: 12) {
                // Pass Button Setup
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        item.status = .pass
                    }
                }) {
                    Text("Pass")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(item.status == .pass ? Color.blue.opacity(0.08) : Color.clear)
                        .foregroundColor(item.status == .pass ? .blue : .primary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(item.status == .pass ? Color.blue : Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Fail Button Setup
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        item.status = .fail
                    }
                }) {
                    Text("Fail")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(item.status == .fail ? Color.red : Color.clear)
                        .foregroundColor(item.status == .fail ? .white : .red)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Dynamic Defect Form Section Expansion Block
            if item.status == .fail {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal)
                    
                    // Failure Context Form Box
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Failure Details")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        TextField("Describe the issue...", text: $item.failureDetails, axis: .vertical)
                            .lineLimit(3...5)
                            .padding(10)
                            .background(Color(.systemGroupedBackground).opacity(0.5))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 0.6)
                            )
                        
                        HStack {
                            Spacer()
                            Text("\(item.failureDetails.count)/250")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Camera Capture Frame View Layer
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Upload Photo (Optional)")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            onPhotoTap()
                        }) {
                            VStack(spacing: 8) {
                                if let img = item.attachedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 120)
                                        .cornerRadius(8)
                                        .clipped()
                                } else {
                                    Image(systemName: "camera")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(spacing: 2) {
                                        Text("Tap to capture or upload")
                                            .font(.footnote)
                                            .foregroundColor(.primary)
                                        Text("JPG, PNG up to 10MB")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color(.systemGroupedBackground).opacity(0.3))
                            .cornerRadius(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), style: StrokeStyle(lineWidth: 1, dash: [3]))
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Dummy Image Picker Wrapper
struct ImagePickerFallback: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Camera Simulator")
                .font(.headline)
            Text("In a real device context, this modal interfaces with UIImagePickerController native platform views.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Simulate Photo Capture") {
                // Return a simple system shape asset as captured payload
                selectedImage = UIImage(systemName: "exclamationmark.triangle.fill")
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                dismiss()
            }
        }
        .padding()
    }
}

// MARK: - Live Preview Component
struct DetailedInspectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailedInspectionView()
        }
    }
}
