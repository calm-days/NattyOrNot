import SwiftUI
import CoreML
import Vision


struct HomeView: View {
    @State private var selection: Int = 0
    
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
                    
                    
                    //here the results
                    Text(classificationLabel)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    
                    
                    
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
                    
                    
                    //Spacer()
                    
                    HStack {
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
                            .padding(15)
                        }
                        .buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 20)))
                        
                        
                        Spacer()
                        Button {
                            
                            self.addNumberWithRollingAnimation()
                            //classifyImage()
                            classify()
                        } label: {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                                .padding(15)
                        }
                        .buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 20)))
                        
                    }
                    .padding(.horizontal, 25)
                    
                    //TabBarView()
                    //.padding(.vertical, 30)
                    Spacer()
                    
                }
            }
            
        }
       
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        
        
        
    }
    
    
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
}










