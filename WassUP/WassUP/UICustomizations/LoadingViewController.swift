import UIKit

class LoadingViewController: UIViewController {
    let loadingImageView = UIImageView()
    let loadingLabel = UILabel()

    let text = "..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("load view")
        // 로딩 화면 이미지 설정
        let loadingImage = UIImage(named: "MainIcon")
        loadingImageView.image = loadingImage
        loadingImageView.contentMode = .scaleAspectFit
        loadingImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingImageView)
        
        // UIImageView 제약 조건 설정
        loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loadingImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // UILabel 추가
        view.addSubview(loadingLabel)
                
        // Auto Layout 제약 설정
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: loadingImageView.bottomAnchor, constant: 20) // 로딩 이미지 뷰 아래쪽으로 20 포인트
        ])
        
        // Label 초기값 설정
        loadingLabel.text = "모 하는지 찾는 중 ..."
        loadingLabel.font = UIFont.boldSystemFont(ofSize: 23)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startRotationAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopRotationAnimation()
    }
    
    private func startRotationAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        loadingImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func stopRotationAnimation() {
        loadingImageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
