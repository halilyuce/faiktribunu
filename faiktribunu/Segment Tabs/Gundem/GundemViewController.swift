//
//  GundemViewController.swift
//  faiktribunu
//
//  Created by Mac on 21.07.2018.
//  Copyright © 2018 Halil İbrahim YÜCE. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import SVPullToRefresh
import SDWebImage
import NightNight

var page = Int()

class GundemViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

        @IBOutlet weak var gCollectionView: UICollectionView!
        
        var basliklar = [String]()
        var resimStr = String()
        var yazinumara = [String]()
        var resimLink = [String]()
        var videoLink = [String]()
        var catResim = [String]()
        var format = [String]()
        var base = [Base]()
        var loadMore = 1
        
        let imagePicker = UIImagePickerController()
        let messageFrame = UIView()
        var activityIndicator = UIActivityIndicatorView()
        var strLabel = UILabel()
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.mixedBackgroundColor = MixedColor(normal: UIColor.groupTableViewBackground, night: UIColor(hexString: "#282828"))
            
            gCollectionView.mixedBackgroundColor = MixedColor(normal: UIColor.groupTableViewBackground, night: UIColor(hexString: "#282828"))
            
            gCollectionView.register(GundemCollectionViewCell.self, forCellWithReuseIdentifier: "GundemCollectionViewCell")
            gCollectionView.register(UINib.init(nibName: "GundemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GundemCollectionViewCell")
            
            
            self.gCollectionView.addPullToRefresh {
                
                self.gCollectionView.pullToRefreshView.startAnimating()
                
                self.basliklar.removeAll(keepingCapacity: false)
                self.resimStr.removeAll(keepingCapacity: false)
                self.yazinumara.removeAll(keepingCapacity: false)
                self.resimLink.removeAll(keepingCapacity: false)
                self.videoLink.removeAll(keepingCapacity: false)
                self.catResim.removeAll(keepingCapacity: false)
                self.format.removeAll(keepingCapacity: false)
                
                
                self.loadList()
                
                
            }
            
            self.gCollectionView.addInfiniteScrolling() {
                
                
                self.gCollectionView.infiniteScrollingView.startAnimating()
                
                self.loadMore += 1
                let urladd = "https://www.faiktribunu.com/wp-json/wp/v2/posts?categories=" + "\(page)" + "&page=" + "\(self.loadMore)"
                
                AF.request(urladd, method: .get, parameters: nil)
                    .responseString { response in
                        
                        switch(response.result) {
                        case .success(_):
                            
                            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                
                                let jsonString: String = "{\"lst\":" + utf8Text + "}"
                                
                                if let item = Mapper<List>().map(JSONString: jsonString){
                                    
                                    if let item = item.lst{
                                        
                                        self.base = item
                                        
                                        for title in item{
                                            
                                            self.basliklar.append((title.title?.rendered)!)
                                            
                                            self.yazinumara.append("\(title.id!)")
                                            
                                            self.format.append((title.format)!)
                                            
                                            self.videoLink.append(title.video_url!)
                                            
                                            let resimUrl = title.betterimage?.details?.sizes?.medium?.source
                                            
                                            self.resimLink.append(resimUrl!)
                                            
                                            self.catResim.append(StaticVariables.homeUrl + StaticVariables.catAvatar + "\(title.categories![0])" + ".png")
                                            
                                            
                                            if item.last?.id == title.id{
                                                self.gCollectionView.reloadData()
                                                self.gCollectionView.infiniteScrollingView.stopAnimating()
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                else{
                                    print("hatalı json")
                                    
                                }
                                
                            }
                            
                        case .failure(_):
                            print("Error message:\(String(describing: response.result.error))")
                            break
                        }
                        
                        
                }
                
                
                
            }
            
            self.gCollectionView.pullToRefreshView.setTitle("Yenilemek için Aşağı Kaydır", forState: 0)
            self.gCollectionView.pullToRefreshView.setTitle("Yenilemekten Vazgeç...", forState: 1)
            self.gCollectionView.pullToRefreshView.setTitle("Yükleniyor...", forState: 2)
            
            self.gCollectionView.delegate = self
            
            self.activityIndicator("Yükleniyor")
            
            
            self.loadList()
            
        }
        
        func loadList(){
            
            self.loadMore = 1
            
            let url = StaticVariables.baseUrl + "posts?categories=" + "\(page)"
            
            AF.request(url, method: .get, parameters: nil)
                .responseString { response in
                    
                    switch(response.result) {
                    case .success(_):
                        
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            
                            let jsonString: String = "{\"lst\":" + utf8Text + "}"
                            
                            if let item = Mapper<List>().map(JSONString: jsonString){
                                
                                if let item = item.lst{
                                    
                                    self.base = item
                                    
                                    if item.count != 0{
                                    
                                    for title in item{
                                        
                                        self.basliklar.append((title.title?.rendered)!)
                                        
                                        self.yazinumara.append("\(title.id!)")
                                        
                                        self.format.append((title.format)!)
                                        
                                        self.videoLink.append(title.video_url!)
                                        
                                        let resimUrl = title.betterimage?.details?.sizes?.medium?.source
                                        
                                        self.resimLink.append(resimUrl!)
                                        
                                        self.catResim.append(StaticVariables.homeUrl + StaticVariables.catAvatar + "\(title.categories![0])" + ".png")
                                        
                                        if item.last?.id == title.id{
                                            self.gCollectionView.reloadData()
                                            self.effectView.removeFromSuperview()
                                            self.gCollectionView.pullToRefreshView.stopAnimating()
                                        }
                                        
                                    }
                                        
                                    }else{
                                        
                                        self.gCollectionView.reloadData()
                                        self.effectView.removeFromSuperview()
                                        self.gCollectionView.pullToRefreshView.stopAnimating()
                                        
                                        
                                        let headerView = UIView()
                                        let headerText = UILabel()
                                        headerText.frame = CGRect(x: 0, y: StaticVariables.screenHeight/2 - 100, width: StaticVariables.screenWidth, height: 50)
                                        headerText.text = "Bu kategoride henüz bir gönderi bulunmamaktadır."
                                        headerText.textColor = UIColor.gray
                                        headerText.numberOfLines = 2
                                        headerText.font = UIFont.boldSystemFont(ofSize: 18.0)
                                        headerText.textAlignment = .center
                                        headerView.addSubview(headerText)
                                        headerView.mixedBackgroundColor = MixedColor(normal: UIColor.groupTableViewBackground, night: UIColor(hexString: "#282828"))
                                        headerView.frame = CGRect(x: 0, y: 0, width: StaticVariables.screenWidth, height: StaticVariables.screenHeight)
                                        
                                        self.view.addSubview(headerView)
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            else{
                                print("hatalı json")
                                
                            }
                            
                        }
                        
                    case .failure(_):
                        print("Error message:\(String(describing: response.result.error))")
                        break
                    }
                    
                    
            }
            
            
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize.init(width: UIScreen.main.bounds.width - 40, height: 230)
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return basliklar.count
        }
        
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GundemCollectionViewCell", for: indexPath) as! GundemCollectionViewCell
            
            cell.mixedBackgroundColor = MixedColor(normal: UIColor.white, night: UIColor(hexString: "#171717"))
            cell.baslik.mixedTextColor = MixedColor(normal: UIColor.black, night: UIColor.white)
            
            if indexPath.row < basliklar.count{
                cell.baslik.text = basliklar[indexPath.row].html2String
                cell.yazarAvatar.sd_setImage(with: URL(string: catResim[indexPath.row]), placeholderImage: UIImage(named: "faiklogo"))
                cell.haberGorseli.sd_setImage(with: URL(string: resimLink[indexPath.row]), placeholderImage: UIImage(named: "faiklogo"))
                cell.yazarAvatar.layer.cornerRadius = cell.yazarAvatar.frame.height/2
                cell.yazarAvatar.clipsToBounds = true
                
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOpacity = 0.25
                cell.layer.shadowOffset = CGSize(width: 0, height: 5)
                cell.layer.shadowRadius = 12
                cell.layer.cornerRadius = 5
                cell.haberGorseli.layer.cornerRadius = 5
                cell.layer.masksToBounds = false
            }
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            let cell = collectionView.cellForItem(at: indexPath) as! GundemCollectionViewCell
            
            let selectedItem = yazinumara[indexPath.row]
            let videoItem = videoLink[indexPath.row]
            let formatItem = format[indexPath.row]
            let avatar = catResim[indexPath.row]
            let gorsel = cell.haberGorseli.image
            
            let mDetayViewController = DetayViewController(nibName: "DetayViewController", bundle: nil)
            mDetayViewController.yaziNumara = selectedItem
            mDetayViewController.contentID = selectedItem
            mDetayViewController.yaziFormat = formatItem
            mDetayViewController.videoLink = videoItem
            mDetayViewController.yazarAvatar = avatar
            mDetayViewController.ilkResim = gorsel!
            self.navigationController?.pushViewController(mDetayViewController, animated: true)
            
        }
        
        func activityIndicator(_ title: String) {
            
            strLabel.removeFromSuperview()
            activityIndicator.removeFromSuperview()
            effectView.removeFromSuperview()
            
            strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
            strLabel.text = title
            strLabel.font = .systemFont(ofSize: 14, weight: .medium)
            strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
            
            effectView.frame = CGRect(x: StaticVariables.screenWidth/2 - strLabel.frame.width/2 , y: StaticVariables.screenHeight/2 - strLabel.frame.height * 2 , width: 160, height: 46)
            effectView.layer.cornerRadius = 15
            effectView.layer.masksToBounds = true
            
            activityIndicator = UIActivityIndicatorView(style: .white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            activityIndicator.startAnimating()
            
            effectView.contentView.addSubview(activityIndicator)
            effectView.contentView.addSubview(strLabel)
            view.addSubview(effectView)
        }
        
}

