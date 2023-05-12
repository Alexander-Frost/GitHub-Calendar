import UIKit

final class DateCell: UICollectionViewCell {
    static let reuseIdentifier = "DateCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.layer.cornerRadius = 2
        self.contentView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private var daysInCurrentYear: Int {
        let date = Date()
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .year, for: date)
        return range?.count ?? 0
    }
    
    private var markedDays: [Int] {
        get {
            return UserDefaults.standard.array(forKey: "markedDays") as? [Int] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "markedDays")
        }
    }
    
    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private let days: [String] = ["Mon", "Wed", "Fri"]
    
    // MARK: - Elements

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var monthStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10

        for month in months {
            let label = UILabel()
            label.text = month
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .gray
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var dayStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        for day in days {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .gray
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalToConstant: 30)
        ])
        return stackView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        let greenButton = UIButton(type: .system)
        greenButton.setTitle("Done ✅", for: .normal)
        greenButton.tintColor = .white
        greenButton.backgroundColor = UIColor(red: 34/255, green: 204/255, blue: 102/255, alpha: 1)
        greenButton.layer.cornerRadius = 5
        greenButton.addTarget(self, action: #selector(greenButtonTapped), for: .touchUpInside)
        
        let greyButton = UIButton(type: .system)
        greyButton.setTitle("Undo ❌", for: .normal)
        greyButton.tintColor = .white
        greyButton.backgroundColor = .gray
        greyButton.layer.cornerRadius = 5
        greyButton.addTarget(self, action: #selector(greyButtonTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(greenButton)
        stackView.addArrangedSubview(greyButton)
        
        return stackView
    }()
    
    // MARK: - Actions
    
    @objc private func greenButtonTapped() {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date())
        if let day = dayOfYear, !markedDays.contains(day) {
            markedDays.append(day)
        }
        collectionView.reloadData()
    }
    
    @objc private func greyButtonTapped() {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date())
        if let day = dayOfYear, let index = markedDays.firstIndex(of: day) {
            markedDays.remove(at: index)
        }
        collectionView.reloadData()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        calculateCellSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(buttonsStackView)
        view.addSubview(monthStackView)
        view.addSubview(dayStackView)
        
        NSLayoutConstraint.activate([
            dayStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            dayStackView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            dayStackView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: dayStackView.trailingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: 200),

            buttonsStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 50),
            
            monthStackView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -8),
            monthStackView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 20),
            monthStackView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Sizing
    
    private func calculateCellSize() {
        let rows = 7
        let cellSize = 200 / CGFloat(rows)
        let scaleFactor: CGFloat = 0.8 // scaling factor, adjust this to make cells smaller or larger
        layout.itemSize = CGSize(width: cellSize * scaleFactor, height: cellSize * scaleFactor)
        collectionView.collectionViewLayout = layout
        collectionView.isScrollEnabled = true

        // Adjust collection view width to fit exactly 7 cells
        collectionView.widthAnchor.constraint(equalToConstant: cellSize * 7).isActive = true

        collectionView.reloadData()
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let totalDays = daysInCurrentYear
        // Make sure the total number of cells is a multiple of 7
        let additionalDays = totalDays % 7
        if additionalDays != 0 {
            return totalDays + 7 - additionalDays
        }
        return totalDays
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.reuseIdentifier, for: indexPath)
        if markedDays.contains(indexPath.row + 1) {
            cell.contentView.backgroundColor = UIColor(red: 34/255, green: 204/255, blue: 102/255, alpha: 1)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        }
        return cell
    }

}
