import SwiftUI
import CoreML
import Vision

struct HomeView: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    
    @State private var steroidsIndex = 0.0
    @State private var naturalIndex = 0.0
    
    private var request: VNCoreMLRequest?
    private let model = NatyOrNotClassifier2()
    @State private var classificationLabel = "fake natty = 0% \n natty = 0%"
    @State private var classifyDidPressed = false
    
    var body: some View {
        VStack {
            ZStack {
                Color.offWhite
                    .edgesIgnoringSafeArea(.bottom)
                
                VStack(spacing: 25){
                    Spacer()
                    
                    imagePickerButton()
                    
                    resultsTab()
                    
                    actionButtons()
                    
                    Spacer()
                }
            }
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
    }
    
    
    func imagePickerButton() -> some View {
        Button {
            resetValues()
            showingImagePicker.toggle()
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
            }
        }
        .buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 20)))
        .padding(.horizontal, 25)
    }
    
    func resultsTab() -> some View {
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
    }
    
    func actionButtons() -> some View {
        HStack {
            Button {
                resetValues()
                showingImagePicker.toggle()
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
    }
    
    
    // MARK: image classifier
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func classify() {
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
        
        steroidsIndex = extractPercentage(from: inputStringFirst, with: numberPattern)
        naturalIndex = extractPercentage(from: inputStringSecond, with: numberPattern)
    }
    
    func extractPercentage(from inputString: String, with pattern: String) -> Double {
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: inputString.utf16.count)
            if let match = regex.firstMatch(in: inputString, options: [], range: range) {
                let numberRange = Range(match.range, in: inputString)!
                if let number = Double(inputString[numberRange]) {
                    return number.rounded(.towardZero)
                } else {
                    print("Failed to convert matched string to Double.")
                }
            } else {
                print("No numbers found in the input string.")
            }
        } else {
            print("Failed to create regular expression.")
        }
        return 0.0
    }
    
    func resetValues() {
        naturalIndex = 0.0
        steroidsIndex = 0.0
        classifyDidPressed = false
    }
}
