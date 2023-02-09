//
//  ContentView.swift
//  NattyOrNot
//
//  Created by Roman Liukevich on 9/18/22.
//

import SwiftUI
import CoreML
import Vision

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

struct NeumorphicButton<S: Shape>: ButtonStyle {
    var shape: S
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(15)
            .background(Background(isPressed: configuration.isPressed, shape: shape))
    }
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func convertToBuffer() -> CVPixelBuffer? {
        
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
}




struct Background<S: Shape>: View {
    var isPressed: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isPressed {
                shape
                    .fill(Color.offWhite)
                    .overlay(
                        shape
                            .stroke(Color.gray, lineWidth: 3)
                            .blur(radius: 4)
                            .offset(x: 2, y: 2)
                            .mask(shape.fill(LinearGradient(Color.black, Color.clear)))
                    )
                    .overlay(
                        shape
                            .stroke(Color.white, lineWidth: 3)
                            .blur(radius: 4)
                            .offset(x: -2, y: -2)
                            .mask(shape.fill(LinearGradient(Color.clear, Color.black)))
                    )
            } else {
                shape
                    .fill(Color.offWhite)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            }
        }
    }
}





struct ContentView: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    
    @State private var steroidsIndex = 0.0
    @State private var naturalIndex = 0.0
    
    @State private var imageDictionary = [
        "natty" : 0.0,
        "fake natty" : 0.0
    ]
    


    
    let model = NatyOrNotClassifier2()
    @State private var classificationLabel: String = "fake natty = 0% \n natty = 0%"
    
    var request: VNCoreMLRequest?
    let image1 = UIImage(named: "chris")

     
    @State var enteredNumber = 40
    @State var total = 0
    
    
    
    
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func addNumberWithRollingAnimation() {
        withAnimation {
            // Decide on the number of animation steps
            let animationDuration = 1000 // milliseconds
            let steps = min(abs(self.enteredNumber), 100)
            let stepDuration = (animationDuration / steps)
            
            // add the remainder of our entered num from the steps
            total += self.enteredNumber % steps
            // For each step
            (0..<steps).forEach { step in
                // create the period of time when we want to update the number
                // I chose to run the animation over a second
                let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                let deadline = DispatchTime.now() + updateTimeInterval
                
                // tell dispatch queue to run task after the deadline
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    // Add piece of the entire entered number to our total
                    self.total += Int(self.enteredNumber / steps)
                }
            }
        }
    }
    
    
    
    
    func classify() {
        total = 0
        guard let image = inputImage,
              let resizedImage = image.resizeImageTo(size:CGSize(width: 224, height: 224)),
              let buffer = resizedImage.convertToBuffer() else {
            return
        }
        
        let output = try? model.prediction(image: buffer)
        
        if let output = output {
            let results = output.classLabelProbs.sorted { $0.1 > $1.1 }
            
            
            //print(results)
            let result = results.map { (key, value) in
                return "\(key) = \(String(format: "%.2f", value * 100))%"
            }.joined(separator: "\n")
            
            let result2 = results.map { (key, value) in
                return value * 100
            }

            
            steroidsIndex = result2[0]
            naturalIndex = result2[1]
            
            //print(steroidsIndex)
            
            self.classificationLabel = result
        }
    }
    

    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.offWhite
                    .ignoresSafeArea()
                
                VStack(spacing: 25){
                    
                    RoundedRectangle(cornerRadius: 20)
                        .overlay {
                            image?
                                .resizable()
                                .scaledToFill()
                        }
                        .foregroundColor(.white)
                        
                        
                        .frame(maxWidth: .infinity, minHeight: 300, idealHeight: 350, maxHeight: 400)
                        .cornerRadius(30)
                        .padding()
                        
                        
                    Text(classificationLabel)
                        .font(.title)
                        .fontWeight(.bold)
//                    HStack(spacing: 40) {
//                        VStack(alignment: .center) {
//                            Text("\(steroidsIndex)%")
//
//                                .font(.largeTitle)
//                                .fontWeight(.black)
//                                .foregroundColor(.purple)
//                            Text("Steroids")
//                        }
//
//                        VStack(alignment: .center) {
//                            Text("\(naturalIndex)%")
//                                .font(.largeTitle)
//                                .fontWeight(.black)
//                                .foregroundColor(.green)
//                            Text("Natural")
//                        }
//
//                    }
                    
                   
                    
                    
                    HStack(spacing: 45) {
                        Button {
                            showingImagePicker.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                                
                                Text("Choose photo from library")
                                    .foregroundColor(.gray)
                            }
                            
                            
                        }
                        .buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 20)))
                        
                        Button {
                            
                            self.addNumberWithRollingAnimation()
                            //classifyImage()
                            classify()
                        } label: {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                        }
                        .buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 20)))
                        
                    }
                }
            }
            .navigationTitle("NattyOrNot")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            
           
            
        }
    }
}


        
        
        
        



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
