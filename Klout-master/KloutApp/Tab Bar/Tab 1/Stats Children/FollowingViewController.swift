//
//  FollowingViewController.swift
//  KloutApp
//
//  Created by Kyle Burns on 3/2/21.
//

import UIKit
import XLPagerTabStrip
import Charts
import GoogleSignIn
import Firebase

class FollowingViewController: UIViewController, IndicatorInfoProvider, ChartViewDelegate {
    
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var timeFrameBtn: UIButton!
    
    var timeframe = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var unixCompare: Int!
    
    var userAccount = Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: "", posts: "", followers: "", following: "")
    
    var lineChart = LineChartView()
    
    
    var weekChartData = [ChartStatistic](arrayLiteral:
                                            ChartStatistic(timestamp: 0, statistic: 0))
    var monthChartData = [ChartStatistic](arrayLiteral:
                                            ChartStatistic(timestamp: 0, statistic: 0))
    var yearChartData = [ChartStatistic](arrayLiteral:
                                            ChartStatistic(timestamp: 0, statistic: 0))
    
    var defaultChartData = [ChartStatistic](arrayLiteral:
                                            ChartStatistic(timestamp: 0, statistic: 0))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(userAccount.socialMediaName == "Youtube"){
            followingNumberLabel.text = "Views: \(userAccount.following)"
        }
        else if(userAccount.socialMediaName == "TikTok"){
            followingNumberLabel.text = "Likes: \(userAccount.following)"
        }
        else{
            followingNumberLabel.text = "Following: \(userAccount.following)"
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for x in 0..<Globals.user.accountSnapshots.count {
            let snap = Globals.user.accountSnapshots[x]
            guard let time: Int = Int(Array(snap)[0].key) else { return }
            
            let snapStats : [String: Any] = Array(snap)[0].value as! [String : Any]
            
            var criteria = ""
            
            if(Globals.user.snapMedia == "tiktok"){
                criteria = "likes"
            }
            else if(Globals.user.snapMedia == "youtube"){
                criteria = "views"
            }
            else if(Globals.user.snapMedia == "instagram"){
                criteria = "following"
            }
            
            guard let stat: Int = Int(snapStats["\(criteria)"] as! String) else { return }
            if(x == 0){
                unixCompare = time
                
                weekChartData.removeAll()
                monthChartData.removeAll()
                yearChartData.removeAll()
                
                weekChartData.append(ChartStatistic(timestamp: time, statistic: stat))
                monthChartData.append(ChartStatistic(timestamp: time, statistic: stat))
                yearChartData.append(ChartStatistic(timestamp: time, statistic: stat))
            }
            else{
                let difference = time - unixCompare
                if(difference <= 29030400){
                    yearChartData.append(ChartStatistic(timestamp: time, statistic: stat))
                }
                if(difference <= 2419200){
                    monthChartData.append(ChartStatistic(timestamp: time, statistic: stat))
                }
                if(difference <= 604800){
                    weekChartData.append(ChartStatistic(timestamp: time, statistic: stat))
                }
            }
        }
        
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        lineChart.center = view.center
        lineChart.rightAxis.enabled = false
        let yAxis = lineChart.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        
        view.addSubview(lineChart)
        var entries = [ChartDataEntry]()
        if(defaultChartData.count <= 1){
            for x in 0..<weekChartData.count {
                entries.append(ChartDataEntry(x: Double(weekChartData[x].timestamp), y: Double(weekChartData[x].statistic)))
            }
        }
        else{
            for x in 0..<defaultChartData.count {
                entries.append(ChartDataEntry(x: Double(defaultChartData[x].timestamp), y: Double(defaultChartData[x].statistic)))
            }
        }

        let set = LineChartDataSet(entries: entries)
        set.drawCirclesEnabled = false
        set.mode = .cubicBezier
        set.lineWidth = 2
        set.setColor(.red)
        set.fill = Fill(color: .red)
        set.fillAlpha = 0.8
        set.drawFilledEnabled = true
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        data.setValueFormatter(formatter)
        lineChart.data = data
        lineChart.isUserInteractionEnabled = false
        lineChart.legend.enabled = false
        
        
        
        
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:timeframe)
        
        lineChart.xAxis.granularity = 1
        //self.barChart.animate(yAxisDuration: 1, easing: .none)
    }
    @IBAction func onChangeTimeFrame(_ sender: Any) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "This Year", style: .default, handler: { alertAction in

            
            self.defaultChartData = self.yearChartData
            
            self.viewDidLayoutSubviews()
            self.timeFrameBtn.setTitle("This Year", for: .normal)
            self.lineChart.animate(xAxisDuration: 1.5, easing: .none)
            }))
        alertController.addAction(UIAlertAction(title: "This Month", style: .default, handler: { alertAction in
            
            
            self.defaultChartData = self.monthChartData

            self.viewDidLayoutSubviews()
            self.timeFrameBtn.setTitle("This Month", for: .normal)
            self.lineChart.animate(xAxisDuration: 1.5, easing: .none)
            }))
        alertController.addAction(UIAlertAction(title: "This Week", style: .default, handler: { alertAction in
            
            self.defaultChartData = self.weekChartData
            
            self.viewDidLayoutSubviews()
            self.timeFrameBtn.setTitle("This Week", for: .normal)
            self.lineChart.animate(xAxisDuration: 1.5, easing: .none)
            }))
        
        
        alertController.modalPresentationStyle = .popover
        self.present(alertController, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if(userAccount.socialMediaName == "Youtube"){
            return IndicatorInfo(title:"Views")
        }
        else if(userAccount.socialMediaName == "TikTok"){
            return IndicatorInfo(title:"Likes")
        }
        else{
            return IndicatorInfo(title:"Following")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
