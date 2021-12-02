//
//  SendData.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//

import SwiftUI
import CoreData
import CryptoKit

struct SendData: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var viewContext
    @State private var showingAlert: Bool = false
    
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
                    if (self.user.id.isEmpty || self.user.hospitals[user.selected_hospital].isEmpty || self.user.disease[user.selected_disease].isEmpty) {
                        showingAlert = true //空欄があるとエラー
                    }else{
                        showingAlert = false
                        SetCoreData(context: viewContext)
                        SaveToResultHolder()
                        //SendDataset()
                        SaveToDoc()
                        self.presentationMode.wrappedValue.dismiss()
                        self.user.isSendData = true

                    }
                    }) {
                        Text("送信")
                            .foregroundColor(Color.white)
                            .font(Font.largeTitle)
                    }
                    .alert(isPresented: $showingAlert){Alert(title: Text("項目に空欄があります"))}
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.black)
                    .padding()
              }
        
            
            }
            
    
    //ResultHolderにテキストデータを格納
    public func SaveToResultHolder(){
        ResultHolder.GetInstance().SetAnswer(q1: stringDate(), q2: user.hashid, q3: user.id, q4: self.user.hospitals[user.selected_hospital], q5: self.user.disease[user.selected_disease], q6: user.free_disease)
    }
    
    
    public func SetCoreData(context: NSManagedObjectContext){
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
        let dateid = Data(newItem.newdateid!.utf8)
        let hashid = SHA256.hash(data: dateid)
        
        user.hashid = hashid.compactMap { String(format: "%02x", $0) }.joined()
        //print(self.user.hashid)
        newItem.newhashid = self.user.hashid
        
        try! context.save()
        self.user.isNewData = true
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
    
    
    //private func saveToDoc (image: UIImage, fileName: String ) -> Bool{
    public func SaveToDoc () -> Bool{
        let images = ResultHolder.GetInstance().GetUIImages()
        let jsonfile = ResultHolder.GetInstance().GetAnswerJson()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let directory = self.user.hashid+".png"
        let fileURL = documentsURL.appendingPathComponent(self.user.hashid+".png")
        //print(fileURL)
        //pngで保存
        for i in 0..<images.count{
            let pngImageData = UIImage.pngData(images[i])
            // jpgで保存する場合
            // let jpgImageData = UIImageJPEGRepresentation(image, 1.0)

            do {
                try pngImageData()!.write(to: fileURL)
                print("successfully saved PNG to doc")
            } catch {
                //エラー処理
                return false
            }
        
        let fileURL2 = documentsURL.appendingPathComponent(self.user.hashid+".json")
        do {
            try jsonfile.write(to: fileURL2, atomically: true, encoding: String.Encoding.utf8)
            print("successfully saved json to doc")
        } catch {
            //エラー処理
            print("Jsonを保存できませんでした")
            return false
        }
        return true
    }
        
        
        
        
        
        
        
        return true
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
        df.dateFormat = "yyyyMMdd"
        let stringDate = df.string(from: user.date)
        return stringDate
    }
    
//    class QuestionAnswerData: Codable{
//        var pq1 = ""
//        var pq2 = ""
//        var pq3 = ""
//        var pq4 = ""
//        var pq5 = ""
//        var pq6 = ""
//    }
    
    
//    public func SetData()-> String{
//        //date形式をstringに変換
//        let df = DateFormatter()
//        df.dateFormat = "yyyyMMdd"
//        let stringDate = df.string(from: user.date)
//
//        //それぞれの項目をdataに格納
//        let data = QuestionAnswerData()
//        data.pq1 = stringDate
//        data.pq2 = user.hashid
//        data.pq3 = user.id
//        data.pq4 = self.user.hospitals[user.selected_hospital]
//        data.pq5 = self.user.disease[user.selected_disease]
//        data.pq6 = user.free_disease
//
//        //jsonに変換
//        let jsonEncoder = JSONEncoder()
//        let jsonData = (try? jsonEncoder.encode(data)) ?? Data()
//        let json = String(data: jsonData, encoding: String.Encoding.utf8)!
//        return json
//    }


}


