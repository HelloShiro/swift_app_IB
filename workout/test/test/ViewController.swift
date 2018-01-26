//
//  ViewController.swift
//  test
//
//  Created by SnoopyKing on 2017/10/21.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    var timer = Timer()
    
    var pickerInfo:[String] = [String]()
    var workoutTime: Int?
    var timeSelectionStr: String?
    var isStart:Bool = false
    var player:AVAudioPlayer = AVAudioPlayer()
    
    func workoutSelection(selection: Int){
        switch selection{
        case 0:
            print("您選擇了熱身")
            workoutTime = 300
            timeSelectionStr = displayMinSecs(time: workoutTime!)
        case 1:
            print("您選擇了低強度訓練")
            workoutTime = 200
            timeSelectionStr = displayMinSecs(time: workoutTime!)
        case 2:
            print("您選擇了高強不訓練")
            workoutTime = 30
            timeSelectionStr = displayMinSecs(time: workoutTime!)
        case 3:
            print("您選擇了休息")
            workoutTime = 10
            timeSelectionStr = displayMinSecs(time: workoutTime!)
        default:
            print("您沒有選擇任何項目")
        }
        timerLabel.text = timeSelectionStr
        startTimerLabel.isEnabled = true
        startTimerLabel.alpha = 1.0
        timerLabel.textColor = UIColor.blue
    }
    func displayMinSecs(time:Int) -> String{
        let minutes = time / 60
        let seconds = time % 60
        
        return String(format: "%02i:%02i",minutes,seconds)
    }
    func startStopTimer(){
        if !isStart{
          timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.decrementWorkoutTime), userInfo: nil, repeats: true)
            isStart = true
            timer.fire()
            startTimerLabel.setTitle("暫停", for: .normal)
        }else{
            timer.invalidate()
            isStart = false
            startTimerLabel.setTitle("開始", for: .normal)

        }
    }
    @objc func decrementWorkoutTime(){
        if workoutTime == 0{
            resetTimer()
            timerLabel.textColor = UIColor.darkGray
            alarm()
        }else{
            workoutTime! -= 1
            timerLabel.text = displayMinSecs(time: workoutTime!)
        }
    }
    func resetTimer(){
        isStart = false
        timer.invalidate()
        workoutTime = 0
        timerLabel.text = "00:00"
        startTimerLabel.setTitle("開始", for: .normal)
        startTimerLabel.isEnabled = false
        startTimerLabel.alpha = 0.3
        timerLabel.textColor = UIColor.blue
    }
    func alarm(){
        let filePath = Bundle.main.path(forResource: "iphone", ofType: "mp3")
        do{
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath!))
            player.play()
        }catch{
            print("error play alarm")
        }
    }
    
    @IBOutlet weak var startTimerLabel: UIButton!
    @IBAction func startTimerAction(_ sender: UIButton) {
        startStopTimer()
    }
    @IBAction func resetTimerAction(_ sender: UIButton) {
        resetTimer()
    }
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
//        for i in 1...5 {
//            let option = "選項 \(i)"
//            pickerInfo.append(option)
//        }
        pickerInfo = ["熱身","低強度訓練","高強度訓練","休息"]
        startTimerLabel.isEnabled = false
        startTimerLabel.alpha = 0.3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerInfo.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerInfo[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        workoutSelection(selection: row)
    }
    
}

