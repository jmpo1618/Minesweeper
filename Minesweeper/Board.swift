//
//  Board.swift
//  Minesweeper
//
//  Created by Juan M Penaranda on 5/26/16.
//  Copyright © 2016 Juan M Penaranda. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class Board: UICollectionViewController {
    
    var altMode = false
    var started = false
    var cells = [[Cell]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 36
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! Cell
    
        // Configure the cell
        cell.label.text = ""
        cell.row = indexPathToRow(indexPath.item)
        cell.col = indexPathToCol(indexPath.item)
        // If needed, add new row to the board.
        if cell.row == 0 {
            cells.append([Cell]())
        }
        // Add cell to appropriate row.
        cells[cell.row!].append(cell)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    /**
        UICollectionViewFlowLayout function to make cells proportional to the screen size.
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width / 7, collectionView.bounds.size.width / 7)
    }
    
    /**
        Function called every time a cell is tapped.
    */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let row = indexPathToRow(indexPath.item)
        let col = indexPathToCol(indexPath.item)
        if !started {
            plantMines(row, startingCol: col)
            updateCellValues()
            started = true
        }
        let selectedCell = cells[row][col]
        if selectedCell.mine != nil {
            print("MINE!")
        } else if altMode{
            // TODO: flag cell
        } else {
            openCell(row, col: col)
        }
        print(selectedCell.row, selectedCell.col)
    }
    
    // MARK: Helpers
    
    func indexPathToRow(indexPath: Int) -> Int {
        return indexPath / 6
    }
    
    func indexPathToCol(indexPath: Int) -> Int {
        return indexPath % 6
    }
    
    // MARK: Setup
    
    /**
        Plants mines in cells based on random
    */
    func plantMines(startingRow: Int, startingCol: Int) {
        for _ in 0..<6 {
            var planted = false
            while !planted {
                let row = Int(arc4random_uniform(6))
                let col = Int(arc4random_uniform(6))
                if cells[row][col].mine == nil && row != startingRow && col != startingCol {
                    cells[row][col].mine = true
                    planted = true
                }
            }
        }
    }
    
    /**
        Finds and sets the cell's number of surrounding mines
    */
    func updateCellValues() {
        for row in 0..<cells.count {
            for col in 0..<cells[row].count {
                var numMines = 0
                if cells[row][col].mine != true {
                    for x in -1...1 {
                        let newRow = row + x
                        for y in -1...1 {
                            let newCol = col + y
                            // Check if the surrounding cell is in bounds and is a mine
                            if newRow >= 0 && newRow < cells.count && newCol >= 0 && newCol < cells[row].count && cells[newRow][newCol].mine == true {
                                numMines += 1
                            }
                        }
                    }
                }
                cells[row][col].neighborMines = numMines
            }
        }
    }
    
    // MARK: Controls
    
    /**
        Opens the specified cell. Uses recursive function reveal zeroes to determine which other neighbors
        to open.
    */
    func openCell(row: Int, col: Int) {
        // Only open cells that haven't been tapped.
        if cells[row][col].tapped == nil {
            revealZeroes(row, col: col)
        }
    }
    
    /**
        Reveals the specified cell and all its neighbors if none of them is a mine.
    */
    func revealZeroes(row: Int, col: Int) {
        // Check if cell coordinates are in bounds and it is untapped,
        if 0 <= row && row < cells.count && 0 <= col && col < cells[row].count && cells[row][col].tapped == nil {
            // Reveal the cell
            cells[row][col].label.text = String(cells[row][col].neighborMines!)
            cells[row][col].tapped = true
            // Call revealZeroes on neighbor cells if it is a zero
            if cells[row][col].neighborMines == 0 {
                revealZeroes(row + 1, col: col)
                revealZeroes(row + 1, col: col + 1)
                revealZeroes(row + 1, col: col - 1)
                revealZeroes(row - 1, col: col)
                revealZeroes(row - 1, col: col + 1)
                revealZeroes(row - 1, col: col - 1)
                revealZeroes(row, col: col + 1)
                revealZeroes(row, col: col - 1)
                /** Maybe switch to this? this is kinda gack ^ but this v calls on itself
                for x in -1...1 {
                    let newRow = row + x
                    for y in -1...1 {
                        let newCol = col + y
                        revealZeroes(newRow, col: newCol)
                    }
                }
                */
            }
        }
    }

    @IBAction func buttonHeld(sender: AnyObject) {
        print("held")
        altMode = true
    }

    @IBAction func buttonReleased(sender: AnyObject) {
        print("released")
        altMode = false
    }
 
}
