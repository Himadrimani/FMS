//
//  ReportDefect.swift
//  FleetCare
//
//  Created by kanak gupta on 24/06/26.
//

import SwiftUI

// MARK: - Native Camera Bridge UI Component
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var capturedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Use camera if available on the device, otherwise fallback safely to photo library (simulator)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        
        init(parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImages.append(image)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// MARK: - Main View Screen
struct ReportDefectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var issueDescription: String = ""
    @State private var attachedImages: [UIImage] = []
    
    // Camera trigger presentation tracker state
    @State private var showCameraSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 1. Blue Active Session Card Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ACTIVE SESSION")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                        
                        Text("Vehicle ID: FX-9921")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Last inspection: Today, 08:45 AM")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.all, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.15), radius: 10, x: 0, y: 5)
                    
                    // 2. Observation Description Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OBSERVATION")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $issueDescription)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.systemGray4).opacity(0.5), lineWidth: 1)
                                )
                            
                            if issueDescription.isEmpty {
                                Text("Describe the issue in detail...")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    // 3. Evidence Camera Module Section (Direct Full Row Launcher)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EVIDENCE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        // Full-width Camera Capture Action Box
                        Button(action: {
                            showCameraSheet = true
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                
                                VStack(spacing: 2) {
                                    Text("Camera Capture")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.primary)
                                    Text("Take a real-time photo of the defect")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            )
                        }
                        
                        // Active Photo Thumbnails Grid Row
                        if !attachedImages.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Captured Photos (\(attachedImages.count))")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(attachedImages.indices, id: \.self) { index in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: attachedImages[index])
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(12)
                                                    .clipped()
                                                    .shadow(color: Color.black.opacity(0.05), radius: 2)
                                                
                                                Button(action: {
                                                    attachedImages.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.black)
                                                        .background(Circle().fill(Color.white))
                                                        .font(.system(size: 18))
                                                        .offset(x: 4, y: -4)
                                                }
                                            }
                                            .padding(.top, 4)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    // 4. Submission Button Block
                    VStack(spacing: 14) {
                        Button(action: {
                            // Run actual reporting submission requests pipeline here
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                Text("Submit Report")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(issueDescription.isEmpty ? Color.blue.opacity(0.6) : Color.blue)
                            .cornerRadius(14)
                        }
                        .disabled(issueDescription.isEmpty)
                        
                        Text("Reports are sent directly to Dispatch & Fleet HQ")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 16)
                    
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).opacity(0.4))
        }
        .navigationTitle("Report Defect")
        .navigationBarTitleDisplayMode(.inline)
        // Direct System Native Camera Modal sheet
        .sheet(isPresented: $showCameraSheet) {
            CameraPicker(isPresented: $showCameraSheet, capturedImages: $attachedImages)
        }
    }
}

// MARK: - Preview Setup
struct ReportDefectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReportDefectView()
        }
    }
}
