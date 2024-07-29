//
//  TimerView.swift
//  Swety
//
//  Created by Davi Guimell on 22/07/24.
//

import SwiftUI

struct TimerView: View {
    var style: AnyShapeStyle = .init(.bar)
   @Binding  var minutes: Int
   @Binding  var seconds: Int
   
    var body: some View {
        HStack(spacing: 0) {
            CustomView("mins", 0...60, $minutes)
            CustomView("secs", 0...60, $seconds)
        }
        .offset(x:-25)
        .background{
            RoundedRectangle(cornerRadius: 10)
                .fill(style)
                .frame(height: 35)
        }
    }
    @ViewBuilder
    private func CustomView(_ title: String, _ range: ClosedRange<Int>,_ selection:Binding<Int> ) -> some View{
        
        PickerView(selection: selection){
            ForEach(range,id:\.self){value in
                Text("\(value)")
                    .frame(width:35, alignment: .trailing)
                    .tag(value)
            }
        }
        .overlay{
            Text(title)
                .font(.callout.bold())
                .frame(width:50, alignment: .leading)
                .lineLimit(1)
                .offset(x:50)
            
        }
    }
    
}


#Preview {
    TimerPreview()
}

fileprivate struct TimerPreview: View {
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    var body: some View {
        TimerView(minutes: $minutes, seconds: $seconds)
    }
}
///HELPER
struct PickerView< Content:View, Selection:Hashable>: View{
    @Binding var selection: Selection
    @ViewBuilder var content: Content
    @State private var isHiden:Bool = false
    var body: some View{
        
        Picker("",selection: $selection){
            
            if !isHiden{
                RemovePickerIndicator{
                    isHiden = true
                }
                
                
            }else{
                content
            }
        }
        .pickerStyle(.wheel)
    }
}

fileprivate
struct RemovePickerIndicator:UIViewRepresentable{
    
    var result: () -> ()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async{
            if let pickerView = view.pickerView{
                if pickerView.subviews.count >= 2{
                    pickerView.subviews[1].backgroundColor = .clear
                }
                result()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView , context: Context) {}
}

fileprivate
extension UIView{
    var pickerView: UIPickerView? {
        if let view = superview as? UIPickerView{
            return view
        }
        return superview?.pickerView
    }
}
