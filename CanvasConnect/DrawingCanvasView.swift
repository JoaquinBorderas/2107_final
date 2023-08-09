//DrawingCanvasView.swift
import FirebaseFirestore
import Firebase
import SwiftUI
import PencilKit
import Combine
import UIKit

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}

extension UIResponder {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct DrawingCanvasView: View {
    @State private var canvasView = PKCanvasView()
    @State private var color: Color = .black
    @State private var lineWidth: CGFloat = 5.0
    @State private var inkType: PKInkingTool.InkType = .pen
    @State private var showingSubmitAlert = false
    @Environment(\.presentationMode) var presentationMode

    func saveDrawing() {
        let db = Firestore.firestore()
        let creatorName = UserDefaults.standard.string(forKey: "userName") ?? "User"
        let drawingData = canvasView.drawing.dataRepresentation()
        var ref: DocumentReference? = nil
        ref = db.collection("drawings").addDocument(data: [
            "creatorName": creatorName,
            "drawing": drawingData,
            "likesArray": [String](),
            "commentsCount": 0,
            "timestamp": FieldValue.serverTimestamp()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        self.presentationMode.wrappedValue.dismiss()
    }

    private func undoAction() {
        canvasView.undoManager?.undo()
    }

    private func redoAction() {
        canvasView.undoManager?.redo()
    }

    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: undoAction) {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(.black)
                }
                Button(action: redoAction) {
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundColor(.black)
                }
                Button(action: clearCanvas) {
                    Image(systemName: "trash")
                        .foregroundColor(.black)
                }
                ColorPicker("", selection: $color)
                Menu {
                    Button("Pen", action: { inkType = .pen })
                    Button("Pencil", action: { inkType = .pencil })
                    Button("Marker", action: { inkType = .marker })
                } label: {
                    Image(systemName: "paintbrush.fill")
                        .foregroundColor(.black)
                }
                Slider(value: $lineWidth, in: 1...60, step: 1)
            }
            .padding()

            DrawingView(canvasView: $canvasView, color: $color, lineWidth: $lineWidth, inkType: $inkType)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .border(Color.gray, width: 1)

            Button(action: {
                showingSubmitAlert = true
            }) {
                Text("Done!")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            .alert(isPresented: $showingSubmitAlert) {
                Alert(
                    title: Text("Ready to post?"),
                    primaryButton: .cancel(),
                    secondaryButton: .default(Text("OK"), action: saveDrawing)
                )
            }

        }
    }
}

struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
    @Binding var inkType: PKInkingTool.InkType

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .white
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.tool = PKInkingTool(inkType, color: UIColor(color), width: lineWidth)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = PKInkingTool(inkType, color: UIColor(color), width: lineWidth)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var drawingView: DrawingView

        init(_ drawingView: DrawingView) {
            self.drawingView = drawingView
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        }
    }
}

struct DrawingCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingCanvasView()
    }
}
