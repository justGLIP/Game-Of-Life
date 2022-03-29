//
//  ViewController.swift
//  Game Of Life
//
//  Created by Alexus =P on 29.03.2022.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var aliveLabel: UILabel!
    
    
    //MARK: Кнопки
    @IBAction func restartButton(_ sender: Any) {
        screenUpdateTimer?.invalidate()
        createLife()
        drawImage()
    }
    
    @IBAction func stopButton(_ sender: Any) {
        screenUpdateTimer?.invalidate()
    }
    
    @IBAction func startButton(_ sender: Any) {
        screenUpdateTimer?.invalidate()
        screenUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true, block: { [self]_ in
            nextCycle()
            drawImage()
        })
    }
    
    let rows = 100
    let cols = 100
    var cellSize = CGSize(width: 0, height: 0)
    var grid:[[Bool]] = []
    var newGrid:[[Bool]] = []
    let canvasSize = CGSize(width: 400, height: 400) //размер холста
    var screenUpdateTimer: Timer?
    let aliveCount = 800
    var stillAlive = 0
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //layoutItems()
        cellSize = CGSize(width: canvasSize.width/CGFloat(cols), height: canvasSize.width/CGFloat(rows))
        createLife()
        drawImage()
    }
    
    //MARK: viewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        layoutItems()
    }
    
    //MARK: layout
    func layoutItems() {
        let dH = (mainView.frame.height - mainView.frame.width)/2
        let dW = (mainView.frame.width - mainView.frame.height)/2
        let gap = restartBtn.frame.width - stopBtn.frame.width - startBtn.frame.width
        
        informationView.frame.origin = CGPoint.zero
        
        if UIDevice.current.orientation.isLandscape { // здесь код для landscape
            
            // informationView
            informationView.frame.size.width = dW
            informationView.frame.size.height = mainView.frame.height
            
            // imageView
            imageView.frame.origin = CGPoint(x: dW, y: 0)
            imageView.frame.size.height = mainView.frame.height
            imageView.frame.size.width = mainView.frame.height
            
            // buttonsView
            buttonsView.frame.origin = CGPoint(x: imageView.frame.maxX, y: 0)
            buttonsView.frame.size.height = mainView.frame.height
            buttonsView.frame.size.width = dW
            
            //Labels
            aliveLabel.frame.origin = CGPoint(x: informationView.bounds.midX - aliveLabel.frame.width/2, y: informationView.bounds.minY + gap)
            
        } else { //здесь код для portrait
            
            // informationView
            informationView.frame.size.width = mainView.frame.width
            informationView.frame.size.height = dH
            
            // imageView
            imageView.frame.origin = CGPoint(x: 0, y: dH)
            imageView.frame.size.height = mainView.frame.width
            imageView.frame.size.width = mainView.frame.width
            
            // buttonsView
            buttonsView.frame.origin = CGPoint(x: 0, y: imageView.frame.maxY)
            buttonsView.frame.size.height = dH
            buttonsView.frame.size.width = mainView.frame.width
            
            //Labels
            aliveLabel.frame.origin = CGPoint(x: informationView.bounds.midX - aliveLabel.frame.width/2, y: informationView.bounds.maxY - gap - aliveLabel.frame.height)
        
        }
        
        //Buttons
        restartBtn.frame.origin = CGPoint(x: buttonsView.bounds.midX - restartBtn.frame.width/2, y: gap)
        stopBtn.frame.origin = CGPoint(x: restartBtn.frame.origin.x, y: gap * 2 + stopBtn.frame.height)
        startBtn.frame.origin = CGPoint(x: restartBtn.frame.maxX - startBtn.frame.width, y: gap * 2 + startBtn.frame.height)
        
        
    }
    
    //MARK: createLife
    func createLife() {
        grid.removeAll()
        var newRow:[Bool] = []
        for _ in 0...rows-1 {
            newRow.removeAll()
            for _ in 0...cols-1 {
                newRow.append(false)
            }
            grid.append(newRow)
        }
        
        //добавляем живые клетки
        for _ in 1...aliveCount {
            var i = Int.random(in: 0...rows-1)
            var j = Int.random(in: 0...cols-1)
            while grid[i][j] {
                i = Int.random(in: 0...rows-1)
                j = Int.random(in: 0...cols-1)
            }
            grid[i][j] = true
        }
        
        // считаем живых
        stillAlive = 0
        for i in 0...rows-1 {
            for j in 0...cols-1 {
                if grid[i][j] {
                    stillAlive += 1
                }
            }
        }
        
    }
    
    //MARK: checkNeighbours
    func checkNeighbours(row: Int, col:Int) -> Bool {
        var totalNeighbours = 0
        //считаем соседей
        for i in -1...1 {
            for j in -1...1 {
                let x = (row+i+rows)%rows
                let y = (col+j+cols)%cols
                if grid[x][y] {
                    totalNeighbours += 1
                }
            }
        }
        //вычитаем себя
        if grid[row][col] {
            totalNeighbours -= 1
        }
        
        //развиваем жизнь
        if grid[row][col] == false && totalNeighbours == 3 {
            return true
        } else if grid[row][col] == true && (totalNeighbours == 2 || totalNeighbours == 3) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: Подсчет следующего поколения
    func nextCycle () {
        //  рассчитываем новое поле
        newGrid = grid
        stillAlive = 0
        for i in 0...rows-1 {
            for j in 0...cols-1 {
                newGrid[i][j] = checkNeighbours(row: i, col: j)
                if newGrid[i][j] {
                    stillAlive += 1
                }
            }
        }
        grid = newGrid
    }
    
    // MARK: рисуем на поле
    func drawImage(){
        
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize.width, height: canvasSize.height))
            let img = renderer.image { context in
                context.cgContext.setStrokeColor(UIColor.black.cgColor)
                for row in 0...rows-1 {
                    for col in 0...cols-1 {
                        context.cgContext.addRect(CGRect(origin: CGPoint(x: cellSize.width * CGFloat(col), y: cellSize.height * CGFloat(row)) , size: cellSize))
                        if grid[row][col] {
                            context.cgContext.drawPath(using: .fillStroke)
                        } else {
                            context.cgContext.setFillColor(UIColor.red.cgColor)
                            context.cgContext.drawPath(using: .stroke)
                        }
                    }
                }
            }
            imageView.image = img
            aliveLabel.text = "Живых клеток: \(stillAlive)"
        //})
    }
    
}

