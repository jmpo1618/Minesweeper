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
    var revealedCells: Int = 0
    var flaggedCells: Int = 0

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
        if altMode {
            // TODO: Add capability of revealing a satisfied cells neighbors
            if selectedCell.tapped == true {
                if revealNeighbors(row, col: col) == false {
                    failureMessage()
                }
            } else {
                flagCells(row, col: col)
            }
        } else if selectedCell.mine != nil {
            failureMessage()
        } else if selectedCell.flagged == nil || selectedCell.flagged == false {
            openCell(row, col: col)
        }
        if flaggedCells == 6 && (flaggedCells + revealedCells) == 36 {
            successMessage()
        }
    }
    
    // MARK: Helpers
    
    func indexPathToRow(indexPath: Int) -> Int {
        return indexPath / 6
    }
    
    func indexPathToCol(indexPath: Int) -> Int {
        return indexPath % 6
    }
    
    /**
        Flags or unflags cells based on flagged status of a given cell
    */
    func flagCells(row: Int, col: Int) {
        let selectedCell = cells[row][col]
        if selectedCell.flagged == true {
            // Flag the unflagged cell
            selectedCell.label.text = ""
            selectedCell.flagged = false
            flaggedCells -= 1
            print("Unflagging row: " + String(row) + ", col: " + String(col))
        } else {
            // Unflag the flagged cell
            selectedCell.label.text = "F"
            selectedCell.flagged = true
            flaggedCells += 1
            print("Flagging row: " + String(row) + ", col: " + String(col))
        }
        print("Current number of flagged cells: " + String(flaggedCells))
    }
    
    /**
        Reveals neighbors of an alleged satisfied cell
        Returns whether the cell was correctly satisfied or not
    */
    func revealNeighbors(row: Int, col: Int) -> Bool {
        var numMines: Int = 0
        var neighborsToReveal: [Cell] = []
        for x in -1...1 {
            let newRow = row + x
            for y in -1...1 {
                let newCol = col + y
                if 0 <= newRow && newRow < cells.count && 0 <= newCol && newCol < cells[row].count && !(row == newRow && col == newCol) {
                    // Ensure cell is in bounds and not the selected cell
                    let neighborCell = cells[newRow][newCol]
                    if (neighborCell.mine == true && neighborCell.flagged == false) || (neighborCell.mine == false && neighborCell.flagged == true) {
                        // User flagged incorrectly
                        print("Incorrect flagging")
                        return false
                    } else {
                        // User flagged correctly
                        if neighborCell.mine == true {
                            // Keep track of number of mines
                            numMines += 1
                        } else {
                            // Keep track of neighbors to reveal if number of mines is satisfied
                            neighborsToReveal.append(neighborCell)
                        }
                    }
                }
            }
        }
        // If the number of mines was satisfied and there was no error, reveal neighbors
        print("numMines: " + String(numMines) + ", Actual mine neighbors: " + String(cells[row][col].neighborMines!))
        if numMines == cells[row][col].neighborMines {
            for cell in 0..<neighborsToReveal.count {
                neighborsToReveal[cell].label.text = String(neighborsToReveal[cell].neighborMines!)
                neighborsToReveal[cell].tapped = true
                revealedCells += 1
            }
        }
        return true
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
            revealCells(row, col: col)
        }
    }
    
    /**
        Reveals the specified cell and all its neighbors if none of them is a mine.
    */
    func revealCells(row: Int, col: Int) {
        // Check if cell coordinates are in bounds and it is untapped,
        if 0 <= row && row < cells.count && 0 <= col && col < cells[row].count && cells[row][col].tapped == nil {
            // Reveal the cell
            cells[row][col].label.text = String(cells[row][col].neighborMines!)
            cells[row][col].tapped = true
            revealedCells += 1
            // Call revealZeroes on neighbor cells if it is a zero
            if cells[row][col].neighborMines == 0 {
                for x in -1...1 {
                    let newRow = row + x
                    for y in -1...1 {
                        let newCol = col + y
                        revealCells(newRow, col: newCol)
                    }
                }
            }
        }
    }

    @IBAction func buttonHeld(sender: AnyObject) {
        if (started) {
            print("held")
            altMode = true
        } else {
            print("Game has not been started")
        }
    }

    @IBAction func buttonReleased(sender: AnyObject) {
        print("released")
        altMode = false
    }
    
    func failureMessage() {
        let failureAlert = UIAlertController(title: "You lost!", message: "You suck!", preferredStyle: UIAlertControllerStyle.Alert)
        failureAlert.addAction(UIAlertAction(title: "OK...", style: UIAlertActionStyle.Default, handler: resetBoard))
        self.presentViewController(failureAlert, animated: true, completion: nil)
    }
    
    func successMessage() {
        let successAlert = UIAlertController(title: "You won!", message: "Nice dude!", preferredStyle: UIAlertControllerStyle.Alert)
        successAlert.addAction(UIAlertAction(title: "Cool.", style: UIAlertActionStyle.Default, handler: resetBoard))
        self.presentViewController(successAlert, animated: true, completion: nil)
    }
    
    func resetBoard(alert: UIAlertAction!) {
        started = false
        revealedCells = 0
        flaggedCells = 0
        for row in 0..<cells.count {
            for col in 0..<cells[0].count {
                cells[row][col].resetCell()
            }
        }
    }
 
}
