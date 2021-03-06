//
//  SoyleyisiViewController.swift
//  faiktribunu
//
//  Created by Mac on 1.08.2018.
//  Copyright © 2018 Halil İbrahim YÜCE. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import SVPullToRefresh
import SDWebImage

class SoyleyisiViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var sCollectionView: UICollectionView!
    
    
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
        
        sCollectionView.register(SoyleyisiCollectionViewCell.self, forCellWithReuseIdentifier: "SoyleyisiCollectionViewCell")
        sCollectionView.register(UINib.init(nibName: "SoyleyisiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SoyleyisiCollectionViewCell")
        
        
        self.sCollectionView.addPullToRefresh {
            
            self.sCollectionView.pullToRefreshView.startAnimating()
            
            
            self.basliklar.removeAll(keepingCapacity: false)
            
            
            self.catResim.removeAll(keepingCapacity: false)
            
            
            self.loadList()
            
            
        }
        
        self.sCollectionView.addInfiniteScrolling() {
            
            
            self.sCollectionView.infiniteScrollingView.startAnimating()
            
            self.loadMore += 1
            let urladd = "https://www.faiktribunu.com/index.php/wp-json/wp/v2/posts?categories=6&page=" + "\(self.loadMore)"
            
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
                                            self.sCollectionView.reloadData()
                                            self.sCollectionView.infiniteScrollingView.stopAnimating()
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
        
        self.sCollectionView.pullToRefreshView.setTitle("Yenilemek için Aşağı Kaydır", forState: 0)
        self.sCollectionView.pullToRefreshView.setTitle("Yenilemekten Vazgeç...", forState: 1)
        self.sCollectionView.pullToRefreshView.setTitle("Yükleniyor...", forState: 2)
        
        self.sCollectionView.delegate = self
        
        self.activityIndicator("Yükleniyor")
        
        
        self.loadList()
        
    }
    
    func loadList(){
        
        self.loadMore = 1
        
        let url = StaticVariables.baseUrl + "posts?categories=6"
        
        AF.request(url, method: .get, parameters: nil)
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
                                        self.sCollectionView.reloadData()
                                        self.effectView.removeFromSuperview()
                                        self.sCollectionView.pullToRefreshView.stopAnimating()
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width - 40, height: 230)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return basliklar.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoyleyisiCollectionViewCell", for: indexPath) as! SoyleyisiCollectionViewCell
        
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
        
        let selectedItem = yazinumara[indexPath.row]
        let videoItem = videoLink[indexPath.row]
        let formatItem = format[indexPath.row]
        
        let mDetayViewController = DetayViewController(nibName: "DetayViewController", bundle: nil)
        mDetayViewController.yaziNumara = selectedItem
        mDetayViewController.yaziFormat = formatItem
        mDetayViewController.videoLink = videoItem
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

