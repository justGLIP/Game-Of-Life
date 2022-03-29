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
    
    @IBAction func restartButton(_ sender: Any) {
        screenUpdateTimer?.invalidate()
        createLife()
        drawImage()
    }
    
    let rows = 50
    let cols = 50
    var cellSize = CGSize(width: 0, height: 0)
    var grid:[[Bool]] = []
    var newGrid:[[Bool]] = []
    let canvasSize = CGSize(width: 400, height: 400) //размер холста
    var screenUpdateTimer: Timer?
    let aliveCount = 300
    
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
            
            //restart Button
            print(mainView.frame.size)
            print(buttonsView.bounds.width)
            print(restartBtn.frame.width/2)
            
            
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
        
        }
        
        //restart Button
        restartBtn.frame.origin = CGPoint(x: buttonsView.bounds.midX - restartBtn.frame.width/2, y: 20) //buttonsView.center.x -
    }
    
    //MARK: createLife
    func createLife() {
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
    
    // MARK: рисуем на поле
    func drawImage(){
        screenUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true, block: { [self]_ in
            //  рассчитываем новое поле
            newGrid = grid
            for i in 0...rows-1 {
                for j in 0...cols-1 {
                    newGrid[i][j] = checkNeighbours(row: i, col: j)
                }
            }
            grid = newGrid
            
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
        })
    }
    
}

