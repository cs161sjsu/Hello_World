

import UIKit
import HFCardCollectionViewLayout
import XLPagerTabStrip
import GoogleSignIn

struct CardInfo {
    var color: UIColor
    var icon: UIImage
}

class KardViewController : UICollectionViewController, HFCardCollectionViewLayoutDelegate, IndicatorInfoProvider {
    
    var cardCollectionViewLayout: HFCardCollectionViewLayout?
    
    @IBOutlet var backgroundNavigationBar: UINavigationBar?
    
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    
    var cardArray: [CardInfo] = []
    
    override func viewDidLoad() {
        self.setupKard()
        super.viewDidLoad()
        if let name = GIDSignIn.sharedInstance()?.currentUser.profile.givenName {
            backLabel.text = "\(name)'s Klout"
        }
        
        //let uid = GIDSignIn.sharedInstance()?.currentUser.userID
        let dimension = round(130 * UIScreen.main.scale);
        let pic = GIDSignIn.sharedInstance()?.currentUser.profile.imageURL(withDimension: UInt(dimension))
        backImageView.af.setImage(withURL: pic!)
        backImageView.layer.borderWidth = 1
        backImageView.layer.masksToBounds = false
        backImageView.layer.borderColor = UIColor.black.cgColor
        backImageView.layer.cornerRadius = backImageView.frame.height/2
        backImageView.clipsToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.reloadInputViews()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title:"Your Kards")
    }
    
    // MARK: CollectionView
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willRevealCardAtIndex index: Int) {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? KardCollectionViewCell {
            cell.cardCollectionViewLayout = self.cardCollectionViewLayout
            cell.cardIsRevealed(true)
        }
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnrevealCardAtIndex index: Int) {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? KardCollectionViewCell {
            cell.cardCollectionViewLayout = self.cardCollectionViewLayout
            cell.cardIsRevealed(false)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cardArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! KardCollectionViewCell
        cell.backgroundColor = self.cardArray[indexPath.item].color
        cell.imageIcon?.image = self.cardArray[indexPath.item].icon
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cardCollectionViewLayout?.revealCardAt(index: indexPath.item)
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempItem = self.cardArray[sourceIndexPath.item]
        self.cardArray.remove(at: sourceIndexPath.item)
        self.cardArray.insert(tempItem, at: destinationIndexPath.item)
    }
 
    // MARK: Actions
    
    @IBAction func goBackAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addCardAction() {
        let index = 0
        let newItem = createCardInfo()
        self.cardArray.insert(newItem, at: index)
        self.collectionView?.insertItems(at: [IndexPath(item: index, section: 0)])
        
        if(self.cardArray.count == 1) {
            self.cardCollectionViewLayout?.revealCardAt(index: index)
        }
    }
    
    @IBAction func deleteCardAtIndex0orSelected() {
        var index = 0
        if(self.cardCollectionViewLayout!.revealedIndex >= 0) {
            index = self.cardCollectionViewLayout!.revealedIndex
        }
        self.cardCollectionViewLayout?.flipRevealedCardBack(completion: {
            self.cardArray.remove(at: index)
            self.collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
        })
    }
    
    // MARK: Private Functions
    
    private func setupKard() {
        if let cardCollectionViewLayout = self.collectionView?.collectionViewLayout as? HFCardCollectionViewLayout {
            self.cardCollectionViewLayout = cardCollectionViewLayout
        }
        
        self.cardCollectionViewLayout?.firstMovableIndex = 0
        self.cardCollectionViewLayout?.cardHeadHeight = 180
        self.cardCollectionViewLayout?.cardShouldExpandHeadHeight = true
        self.cardCollectionViewLayout?.cardShouldStretchAtScrollTop = true
        self.cardCollectionViewLayout?.cardMaximumHeight = 0
        self.cardCollectionViewLayout?.bottomNumberOfStackedCards = 5
        self.cardCollectionViewLayout?.bottomStackedCardsShouldScale = true
        self.cardCollectionViewLayout?.bottomCardLookoutMargin = 10
        self.cardCollectionViewLayout?.spaceAtTopForBackgroundView = 0.94
        self.cardCollectionViewLayout?.spaceAtTopShouldSnap = true
        self.cardCollectionViewLayout?.spaceAtBottom = 0
        self.cardCollectionViewLayout?.scrollAreaTop = 120
        self.cardCollectionViewLayout?.scrollAreaBottom = 120
        self.cardCollectionViewLayout?.scrollShouldSnapCardHead = false
        self.cardCollectionViewLayout?.scrollStopCardsAtTop = true
        self.cardCollectionViewLayout?.bottomStackedCardsMinimumScale = 0.94
        self.cardCollectionViewLayout?.bottomStackedCardsMaximumScale = 1.0
        
        let count = 1
        
        for index in 0..<count {
            self.cardArray.insert(createCardInfo(), at: index)
        }
        
        self.collectionView?.reloadData()
    }
    
    private func createCardInfo() -> CardInfo {
        //let icons: []
        let icon = backImageView.image
        //let newItem = CardInfo(color: self.getRandomColor(), icon: icon)
        let newItem = CardInfo(color: .gray, icon: icon ?? UIImage(systemName: "person.circle")!)
        return newItem
    }
    
    private func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

