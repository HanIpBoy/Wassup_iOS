import UIKit

//class GroupTimeTableViewController: UIViewController {
//
////    let timeSlots = ["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "24:00" ] // 시간대 목록
////    let days = ["월", "화", "수", "목", "금", "토", "일"] // 요일 목록
////
//
//    @IBOutlet weak var groupNameLabel: UILabel!
//
//    @IBOutlet weak var timeTableView: UICollectionView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//}

//import UIKit
//
//class GroupTimeTableViewController: UIViewController {
//    var collectionView: UICollectionView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        configureCollectionView()
//    }
//    
//    func configureCollectionView() {
//        // UICollectionViewFlowLayout 대신에 UICollectionViewCompositionalLayout을 사용하여 레이아웃 구성
//        let layout = createLayout()
//        
//        // UICollectionView 인스턴스 생성 및 설정
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
//        collectionView.backgroundColor = .white
//        collectionView.dataSource = self
//        collectionView.register(TimeTableCollectionViewCell.self, forCellWithReuseIdentifier: "TimeTableCell")
//        
//        view.addSubview(collectionView)
//    }
//    
//    func createLayout() -> UICollectionViewLayout {
//        // 2열로 구성하기 위해 NSCollectionLayoutGroup을 사용
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        // 수평으로 셀 배치하기 위해 NSCollectionLayoutGroup을 사용
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        // Section을 만들어서 group을 포함
//        let section = NSCollectionLayoutSection(group: group)
//        
//        // UICollectionViewCompositionalLayout에 section을 설정하여 레이아웃 생성
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }
//}
//
//extension GroupTimeTableViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1 // 섹션의 개수 (1개의 섹션)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 10 // 각 섹션의 아이템 개수 (10개의 셀)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableCell", for: indexPath) as! TimeTableCollectionViewCell
//        
//        // 셀의 내용 설정
//        cell.label.text = "Cell \(indexPath.item)"
//        
//        return cell
//    }
//}
//
//class TimeTableCollectionViewCell: UICollectionViewCell {
//    var label: UILabel!
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        configureCell()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configureCell() {
//        // 셀의 내용을 나타내는 UILabel 추가
//        label = UILabel(frame: contentView.bounds)
//        label.textAlignment = .center
//        label.textColor = .black
//        contentView.addSubview(label)
//        
//        contentView.backgroundColor = .lightGray
//        contentView.layer.borderWidth = 1.0
//        contentView.layer.borderColor = UIColor.darkGray.cgColor
//    }
//}
