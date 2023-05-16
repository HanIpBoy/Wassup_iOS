//
//  TabBarViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/27.
//

import UIKit

class TabBarViewController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
        
    // 탭바 중 작성 탭을 모달로 띄우기 위한 코드
    // 해당 작업을 위해 TabBarDelegate를 이용하여 프로토콜을 구현
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 탭바에서 작성 탭은 인덱스 값이 1이기 때문에 1을 제외한 나머지 인덱스에서는 정상 작동 하게끔 한다.
        // 인덱스는 0~3
        guard let index = tabBarController.viewControllers?.firstIndex(of:viewController), index == 1 else {
            return true
        }

        // 인덱스가 1일 때, 작동하는 코드
        // write 스토리보드를 연관되는 뷰컨트롤러로 매칭시켜 모달 형태로 띄운다.
        let storyboard = UIStoryboard(name: "Write", bundle: nil)
        guard let writeVC = storyboard.instantiateViewController(withIdentifier: "Write") as? WriteViewController else { return true }
        
        self.present(writeVC, animated: true, completion: nil)

        // 해당 인덱스인 1번에서는 정상 작동하지 않도록 한다.
        return false
        
    }
    

}


