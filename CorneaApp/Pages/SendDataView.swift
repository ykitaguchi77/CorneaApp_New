//
//  SendData.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//

import SwiftUI
import CoreData

struct SendData: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        
        VStack{
                GeometryReader { bodyView in
                    VStack{
                        Text("内容を確認してください").padding().foregroundColor(Color.black)
                            .font(Font.title)
                        
                        ScrollView(.vertical){
                            GetImageStack(images: ResultHolder.GetInstance().GetUIImages(), shorterSide: GetShorterSide(screenSize: bodyView.size))
                        }
                        
                        HStack{
                            Text("撮影日時:")
                            Text(self.user.date, style: .date)
                        }
                        Text("ID: \(self.user.id)")
                        Text("施設: \(self.user.hospitals[user.selected_hospital])")
                        Text("診断名: \(user.disease[user.selected_disease])")
                        Text("自由記載: \(self.user.free_disease)")
                    }
                }
                            
                Spacer()
                Button(action: {
                    SetCoreData(context: viewContext)
                    //SendDataset()
                    self.presentationMode.wrappedValue.dismiss()
                    self.user.isSendData = true
                    
                }) {
                    Text("送信")
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.black)
                    .padding()
                .onAppear{
                    ResultHolder.GetInstance().SetAnswer(q1: stringDate(), q2: user.id, q3: self.user.hospitals[user.selected_hospital], q4: self.user.disease[user.selected_disease], q5: user.free_disease)
                    //ResultHolderにテキストデータを格納
                }
              }
        
            
            }
            

    
    func SetCoreData(context: NSManagedObjectContext){
        let newItem = Item(context: viewContext)
        newItem.newdate = self.user.date
        newItem.newid = self.user.id
        newItem.newhospitals = self.user.hospitals[user.selected_hospital]
        newItem.newdisease = self.user.disease[user.selected_disease]
        newItem.newfreedisease = self.user.free_disease
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyyMMdd"
        
        newItem.newdateid = "\(dateFormatter.string(from:self.user.date))-\(self.user.id)"

        try! context.save()
        self.user.isNewData = true
        }
    
    

    public func GetImageStack(images: [UIImage], shorterSide: CGFloat) -> some View {
            let padding: CGFloat = 10.0
            let imageLength = shorterSide / 3 + padding * 2
            let colCount = Int(shorterSide / imageLength)
            let rowCount = Int(ceil(Float(images.count) / Float(colCount)))
            return VStack(alignment: .leading) {
                ForEach(0..<rowCount){
                    i in
                    HStack{
                        ForEach(0..<colCount){
                            j in
                            if (i * colCount + j < images.count){
                                let image = images[i * colCount + j]
                                Image(uiImage: image).resizable().frame(width: imageLength*2.4, height: imageLength*2.4).padding(padding)
                            }
                        }
                    }
                }
            }
            .border(Color.black)
        }
    
    public func GetShorterSide(screenSize: CGSize) -> CGFloat{
        let shorterSide = (screenSize.width < screenSize.height) ? screenSize.width : screenSize.height
        return shorterSide
    }
    
    
    public func stringDate()->String{
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        let stringDate = df.string(from: user.date)
        return stringDate
    }
    
    
    /*
    public func SetData()-> String{
        //date形式をstringに変換
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        let stringDate = df.string(from: user.date)
        
        //それぞれの項目をdataに格納
        let data = QuestionAnswerData()
        data.pq1 = stringDate
        data.pq2 = user.id
        data.pq3 = self.user.hospitals[user.selected_hospital]
        data.pq4 = self.user.disease[user.selected_disease]
        data.pq5 = user.free_disease
        
        //jsonに変換
        let jsonEncoder = JSONEncoder()
        let jsonData = (try? jsonEncoder.encode(data)) ?? Data()
        let json = String(data: jsonData, encoding: String.Encoding.utf8)!
        return json
    }
    */
    
    class QuestionAnswerData: Codable{
        var pq1 = ""
        var pq2 = ""
        var pq3 = ""
        var pq4 = ""
        var pq5 = ""
    }

    
    public func SendDataset(){
        var errorPointer: NSError?
        let textBlobURL = URL(string: ConstHolder.TEXTCONTAINERURI)
        let textBlobURI = AZSStorageUri(primaryUri: textBlobURL!)
        let textBlobContainer = AZSCloudBlobContainer(storageUri: textBlobURI, error: &errorPointer)
        let textBlob = textBlobContainer.blockBlobReference(fromName: ConstHolder.QUESTIONFILENAME)
        textBlob.upload(fromText: ResultHolder.GetInstance().GetAnswerJson(), completionHandler: { error in
            if (error != nil) {
                print(error!)
            } else{
                print("successfully uploaded text")
            }
        })

        let imageBlobURL = URL(string: ConstHolder.IMAGECONTAINERURI)
        let imageBlobURI = AZSStorageUri(primaryUri: imageBlobURL!)
        let imageBlobContainer = AZSCloudBlobContainer(storageUri: imageBlobURI, error: &errorPointer)
        let images = ResultHolder.GetInstance().GetUIImages()
        for i in 0..<images.count{
            let blob2 = imageBlobContainer.blockBlobReference(fromName: String(i) + ".png")
            blob2.upload(from: images[i].pngData() ?? Data(), completionHandler: { error in
                    if (error != nil) {
                        print(error!)
                    } else{
                        print("successfully uploaded image")
                    }
            })
        }
    }
    
    
    /*
    func getIsLandscape() -> Bool{
        var isLandscape = false
        switch UIApplication.shared.windows.first?.windowScene?.interfaceOrientation{
        case .portrait:
            isLandscape = false
        case .portraitUpsideDown:
            isLandscape = false
        case .landscapeLeft:
            isLandscape = true
        case .landscapeRight:
            isLandscape = true
        default:
            print("unknown orientation")
            break
        }
        
        return isLandscape
    }
    */
}


/*
struct SendData_Previews: PreviewProvider {
    static var previews: some View {
        SendData()
    }
}
*/
