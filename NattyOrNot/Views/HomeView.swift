import SwiftUI
import CoreML
import Vision


struct HomeView: View {
    @State private var selection: Int = 0
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    
    @State private var steroidsIndex: Double = 0.0
    @State private var naturalIndex: Double = 0.0
    
    let model = NatyOrNotClassifier2()
    @State private var classificationLabel: String = "fake natty = 0% \n natty = 0%"
    @State private var classifyDidPressed: Bool = false
    
    var request: VNCoreMLRequest?
    let image1 = UIImage(named: "chris")
    
    @State var enteredNumber = 0
    @State var total = 0

    
    var body: some View {
        
        VStack {
            ZStack {
                Color.offWhite
                    //.ignoresSafeArea()
                    .edgesIgnoringSafeArea(.bottom)
                
                VStack(spacing: 25){
                    Spacer()
                    Button {
                        showingImagePicker.toggle()
                        naturalIndex = 0.0
                        steroidsIndex = 0.0
                        classifyDidPressed = false
                    } label: {
                        HStack {
                            RoundedRectangle(cornerRadius: 30)
                                .overlay {
                                    image?
                                        .resizable()
                                        .scaledToFill()
                                }
                                .foregroundColor(.offWhite)
                                .frame(maxWidth: .infinity, minHeight: 400, idealHeight: 550, maxHeight: 800)
                                .cornerRadius(20)
                            
                            //.padding()
                        }
                    }
                    .buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 20)))
                    .padding(.horizontal, 25)
                    
                    
                    // MARK: results tab
                    
                    HStack(spacing: 40) {
                        VStack(alignment: .center) {
                            Text("\(steroidsIndex.formatted())%")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .foregroundColor(.purple)
                            Text("Steroids")
                        }
                        
                        VStack(alignment: .center) {
                            Text("\(naturalIndex.formatted())%")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .foregroundColor(.green)
                            Text("Natural")
                        }
                    }

                    HStack {
                        Button {
                            showingImagePicker.toggle()
                            naturalIndex = 0.0
                            steroidsIndex = 0.0
                            classifyDidPressed = false
                        } label: {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                                
                                Text("Choose photo from library")
                                    .foregroundColor(.gray)
                            }
                            .padding(15)
                        }
                        .buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 20)))
                        
                        Spacer()
                        Button {
                            
                            if !classifyDidPressed {
                                classify()
                                writeDescription()
                                //addNumberWithRollingAnimation()
                                classifyDidPressed = true
                            }
                        } label: {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                                .padding(15)
                        }
                        .buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 20)))
                    }
                    .padding(.horizontal, 25)
                    Spacer()
                }
            }
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
    }
    
    
    // MARK: image classifier
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
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
            let result = results.map { (key, value) in
                return "\(key) = \(String(format: "%.f", value * 100))%"
            }.joined(separator: "\n")
            self.classificationLabel = result
        }
    }
    
    
    
    func writeDescription() {
        let array = classificationLabel.components(separatedBy: CharacterSet.newlines)
        let inputStringFirst = array[0].hasPrefix("f") ? array[0] : array[1]
        let inputStringSecond = array[0].hasPrefix("f") ? array[1] : array[0]
        let numberPattern = #"[-+]?(\d*[.])?\d+"#
        
        if let regex = try? NSRegularExpression(pattern: numberPattern, options: []) {
            let range = NSRange(location: 0, length: inputStringFirst.utf16.count)
            if let match = regex.firstMatch(in: inputStringFirst, options: [], range: range) {
                let numberRange = Range(match.range, in: inputStringFirst)!
                if let number = Double(inputStringFirst[numberRange]) {
                    steroidsIndex = number.rounded(.towardZero)
                } else {
                    print("Failed to convert matched string to Double.")
                }
            } else {
                print("No numbers found in the input string.")
            }
        } else {
            print("Failed to create regular expression.")
        }
        
        
        if let regex = try? NSRegularExpression(pattern: numberPattern, options: []) {
            let range = NSRange(location: 0, length: inputStringSecond.utf16.count)
            if let match = regex.firstMatch(in: inputStringSecond, options: [], range: range) {
                let numberRange = Range(match.range, in: inputStringSecond)!
                if let number = Double(inputStringSecond[numberRange]) {
                    naturalIndex = number.rounded(.towardZero)
                    enteredNumber = Int(naturalIndex)
                } else {
                    print("Failed to convert matched string to Double.")
                }
            } else {
                print("No numbers found in the input string.")
            }
        } else {
            print("Failed to create regular expression.")
        }
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
}
